# Mozilla-owned Entra identity for Firefox Windows App SDK push notification
# work. This replaces the personal identity used by the Bug 1803416 prototype.
#
# WNS requires a multi-tenant application registration and a service principal.
# The service principal object ID is the remote identifier that Firefox uses to
# request a WNS channel. The application client ID and Mozilla tenant ID are used
# by the sender to request an access token for https://wns.windows.com/.default.
#
# A client credential is not created here. Add one only after the WNS sender and
# its approved secret store are defined. Never commit or output the credential.

data "azuread_user" "aborondo" {
  user_principal_name = "aborondo@mozilla.com"
}

locals {
  firefox_wns_owners = setunion(
    toset(data.azuread_group.relops.members),
    toset([data.azuread_user.aborondo.object_id]),
  )
}

resource "azuread_application" "firefox_wns" {
  display_name     = "Firefox WNS"
  description      = "Mozilla-owned identity for Firefox Windows App SDK push notification work (RELOPS-2495, Bug 1803416)."
  sign_in_audience = "AzureADMultipleOrgs"
  owners           = local.firefox_wns_owners
}

resource "azuread_service_principal" "firefox_wns" {
  client_id                    = azuread_application.firefox_wns.client_id
  app_role_assignment_required = false
  owners                       = local.firefox_wns_owners
  tags                         = concat(["name:firefox-wns"], local.sp_tags)
}

output "firefox_wns_client_id" {
  description = "Application client ID used for WNS activation and access-token requests."
  value       = azuread_application.firefox_wns.client_id
}

output "firefox_wns_service_principal_object_id" {
  description = "Service principal object ID used as the Windows App SDK WNS remote identifier."
  value       = azuread_service_principal.firefox_wns.object_id
}

output "firefox_wns_tenant_id" {
  description = "Mozilla Entra tenant ID used for WNS access-token requests."
  value       = data.azuread_client_config.current.tenant_id
}
