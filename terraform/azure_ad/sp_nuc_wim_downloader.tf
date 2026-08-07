# Service principal used by the on-site MDC1 server to DOWNLOAD baked NUC WIMs
# from the private (firewalled) storage account (azure_fxci/nuc-wim-storage.tf).
#
# Entra auth path: the SP is granted "Storage Blob Data Reader" on the 'captured'
# container in azure_fxci (via var.nuc_wim_downloader_object_id = this object_id).
# The MDC1 server authenticates with the SP client_id + secret (stored in
# kv-central-us-key) using azcopy/az, e.g.:
#   az login --service-principal -u <client_id> -p <secret> --tenant <tenant>
#   azcopy copy "https://hardwareimaging.blob.core.windows.net/captured/<wim>" . --auth-mode login
#
# If the MDC1 server cannot do Entra auth, skip this SP and instead issue a
# read-only, time-boxed SAS on the 'captured' container and store it in Key Vault.

resource "azuread_application" "nuc_wim_downloader" {
  display_name = "sp-relops-nuc-wim-downloader"
  owners       = [data.azuread_user.mcornmesser.object_id]
}

resource "azuread_service_principal" "nuc_wim_downloader" {
  client_id                    = azuread_application.nuc_wim_downloader.client_id
  app_role_assignment_required = false
  tags                         = local.sp_tags
}

# Client secret for the on-site server. Store the value in kv-central-us-key;
# do not commit it. (Rotate periodically.)
resource "azuread_application_password" "nuc_wim_downloader" {
  application_id = azuread_application.nuc_wim_downloader.id
  display_name   = "mdc1-server"
  end_date       = "2027-07-21T00:00:00Z"
}

output "nuc_wim_downloader_object_id" {
  description = "Feed into azure_fxci var.nuc_wim_downloader_object_id to grant Blob Data Reader."
  value       = azuread_service_principal.nuc_wim_downloader.object_id
}

output "nuc_wim_downloader_client_id" {
  value = azuread_application.nuc_wim_downloader.client_id
}
