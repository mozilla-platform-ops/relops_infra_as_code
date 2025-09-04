data "azuread_service_principal" "wiz_for_azure" {
  # Only perform lookup if we're using existing SP and object_id is not directly provided
  count     = var.use_existing_service_principal && var.wiz_app_object_id == "" ? 1 : 0
  client_id = var.wiz_app_id
}

data "azuread_application_published_app_ids" "well_known" {}

# Define the Wiz Disk Analyzer - Scanner app ID for an existing app
data "azuread_service_principal" "wiz_da_scanner_sp" {
  client_id = var.wiz_da_scanner_app_id
}
