# Define the Wiz Disk Analyzer - Scanner app ID for an existing app
data "azuread_service_principal" "wiz_da_scanner_sp" {
  client_id = var.wiz_da_scanner_app_id
}

# Create the Wiz custom roles with a time delay to allow the Azure dataplane to catch up. You can leave the max default variable to the default.
# The creation of Azure custom role can take several minutes and needs to be completed before the role assignments are made, or the role assignments will simply not happen.
# Similarly, you may notice that deletion of the custom role can take several minutes to complete when you run `terraform destroy`.
resource "time_sleep" "wait_for_az_dataplane_data_roles" {
  create_duration = var.azure_wait_timer
  depends_on = [
    azurerm_role_definition.wiz_disk_analyzer_role,
    azurerm_role_definition.wiz_data_scanning_role,
    azurerm_role_definition.wiz_serverless_scanning_role
  ]
}

resource "azurerm_role_definition" "wiz_disk_analyzer_role" {
  name        = var.wiz_disk_analyzer_role_name
  scope       = local.scope
  description = "Wiz DiskAnalyzer Role"
  permissions {
    actions          = local.DISK_ANALYZER_CUSTOM_ROLE_ACTIONS
    not_actions      = []
    data_actions     = []
    not_data_actions = []
  }

  assignable_scopes = [
    local.scope
  ]
}

# Optional data scanning role
resource "azurerm_role_definition" "wiz_data_scanning_role" {
  # Create 1 of this resource if enable_data_scanning is true
  # Else create 0 of this resource
  count       = (var.enable_data_scanning) ? 1 : 0
  name        = var.wiz_data_scanning_role_name
  scope       = local.scope
  description = "Wiz Data Scanning Role"

  permissions {
    actions          = local.DATA_SCANNING_CUSTOM_ROLE_ACTIONS
    not_actions      = []
    data_actions     = []
    not_data_actions = []
  }

  assignable_scopes = [
    local.scope
  ]
}

# Optional serverless scanning role
resource "azurerm_role_definition" "wiz_serverless_scanning_role" {
  # Create 1 of this resource if enable_serverless_scanning is true
  # Else create 0 of this resource
  count       = (var.enable_serverless_scanning) ? 1 : 0
  name        = var.wiz_serverless_scanning_role_name
  scope       = local.scope
  description = "Wiz Serverless Scanning Role"

  permissions {
    actions          = local.SERVERLESS_SCANNING_CUSTOM_ROLE_ACTIONS
    not_actions      = []
    data_actions     = []
    not_data_actions = []
  }

  assignable_scopes = [
    local.scope
  ]
}

resource "azurerm_role_assignment" "wiz_da_scanner_disk_analyzer_role_custom_assign" {
  scope                = local.scope
  principal_id         = data.azuread_service_principal.wiz_da_scanner_sp.id
  role_definition_name = azurerm_role_definition.wiz_disk_analyzer_role.name
  depends_on           = [time_sleep.wait_for_az_dataplane_data_roles]
}

/*
Optional Wiz DA Scanner  DSPM (Data Scanning) assignments
*/
resource "azurerm_role_assignment" "wiz_da_scanner_disk_analyzer_role_storage_blob_assign" {
  count                = (var.enable_data_scanning) ? 1 : 0
  scope                = local.scope
  principal_id         = data.azuread_service_principal.wiz_da_scanner_sp.id
  role_definition_name = "Storage Blob Data Reader"
}
resource "azurerm_role_assignment" "wiz_da_scanner_disk_analyzer_role_storage_file_assign" {
  count                = (var.enable_data_scanning) ? 1 : 0
  scope                = local.scope
  principal_id         = data.azuread_service_principal.wiz_da_scanner_sp.id
  role_definition_name = "Storage File Data Privileged Reader"
}
resource "azurerm_role_assignment" "wiz_da_scanner_data_scanning_role_assign" {
  count                = (var.enable_data_scanning) ? 1 : 0
  scope                = local.scope
  principal_id         = data.azuread_service_principal.wiz_da_scanner_sp.id
  role_definition_name = azurerm_role_definition.wiz_data_scanning_role[count.index].name
  depends_on           = [time_sleep.wait_for_az_dataplane_data_roles]
}

/*
Optional Wiz DA Scanner Serverless Scanning assignments
*/
resource "azurerm_role_assignment" "wiz_da_scanner_serverless_scanning_role_assign" {
  count                = (var.enable_serverless_scanning) ? 1 : 0
  scope                = local.scope
  principal_id         = data.azuread_service_principal.wiz_da_scanner_sp.id
  role_definition_name = azurerm_role_definition.wiz_serverless_scanning_role[count.index].name
  depends_on           = [time_sleep.wait_for_az_dataplane_data_roles]
}

/*
Optional Wiz DA Scanner OpenAI Scanning assignments
*/
resource "azurerm_role_assignment" "wiz_da_scanner_openai_scanning_role_assign" {
  count                = (var.enable_openai_scanning) ? 1 : 0
  scope                = local.scope
  principal_id         = data.azuread_service_principal.wiz_da_scanner_sp.id
  role_definition_name = "Cognitive Services OpenAI User"
}

locals {
  DISK_ANALYZER_CUSTOM_ROLE_ACTIONS = [
    "Microsoft.Compute/disks/beginGetAccess/action",
    "Microsoft.Compute/disks/read",
    "Microsoft.Compute/galleries/images/versions/read",
    "Microsoft.Compute/snapshots/beginGetAccess/action",
    "Microsoft.Compute/snapshots/delete",
    "Microsoft.Compute/snapshots/endGetAccess/action",
    "Microsoft.Compute/snapshots/read",
    "Microsoft.Compute/snapshots/write",
    "Microsoft.ContainerRegistry/registries/pull/read",
    "Microsoft.KeyVault/vaults/privateEndpointConnections/read",
    "Microsoft.KeyVault/vaults/privateEndpointConnections/write",
    "Microsoft.Resources/subscriptions/read",
    "Microsoft.authorization/locks/read"
]

  DATA_SCANNING_CUSTOM_ROLE_ACTIONS = [
    "Microsoft.DocumentDB/databaseAccounts/read",
    "Microsoft.DocumentDB/databaseAccounts/readonlykeys/action",
    "Microsoft.Insights/metrics/read",
    "Microsoft.Sql/locations/capabilities/read",
    "Microsoft.Sql/servers/databases/read",
    "Microsoft.Sql/servers/databases/usages/read",
    "Microsoft.Sql/servers/databases/write",
    "Microsoft.Sql/servers/read",
    "Microsoft.Storage/storageAccounts/inventoryPolicies/write",
    "Microsoft.Storage/storageAccounts/privateEndpointConnections/read",
    "Microsoft.Storage/storageAccounts/privateEndpointConnections/write"
]

  SERVERLESS_SCANNING_CUSTOM_ROLE_ACTIONS = [
    "Microsoft.Web/hostingenvironments/sites/read",
    "Microsoft.Web/serverfarms/sites/read",
    "Microsoft.Web/sites/backup/action",
    "Microsoft.Web/sites/backup/read",
    "Microsoft.Web/sites/backups/delete",
    "Microsoft.Web/sites/backups/list/action",
    "Microsoft.Web/sites/backups/read",
    "Microsoft.Web/sites/config/list/Action",
    "Microsoft.Web/sites/config/read",
    "Microsoft.Web/sites/config/snapshots/read",
    "Microsoft.Web/sites/extensions/*/action",
    "Microsoft.Web/sites/extensions/*/read",
    "Microsoft.Web/sites/functions/*/read",
    "Microsoft.Web/sites/functions/read",
    "Microsoft.Web/sites/host/listkeys/action",
    "Microsoft.Web/sites/hostruntime/*/read",
    "Microsoft.Web/sites/instances/read",
    "Microsoft.Web/sites/listbackups/action",
    "Microsoft.Web/sites/operationresults/read",
    "Microsoft.Web/sites/operations/read",
    "Microsoft.Web/sites/publish/action",
    "Microsoft.Web/sites/publishxml/action",
    "Microsoft.Web/sites/read",
    "Microsoft.Web/sites/slots/backup/action",
    "Microsoft.Web/sites/slots/backup/read",
    "Microsoft.Web/sites/slots/backups/delete",
    "Microsoft.Web/sites/slots/backups/list/action",
    "Microsoft.Web/sites/slots/backups/read",
    "Microsoft.Web/sites/slots/config/list/Action",
    "Microsoft.Web/sites/slots/config/read",
    "Microsoft.Web/sites/slots/config/snapshots/read",
    "Microsoft.Web/sites/slots/extensions/*/action",
    "Microsoft.Web/sites/slots/extensions/*/read",
    "Microsoft.Web/sites/slots/functions/*/read",
    "Microsoft.Web/sites/slots/functions/read",
    "Microsoft.Web/sites/slots/host/listkeys/action",
    "Microsoft.Web/sites/slots/instances/read",
    "Microsoft.Web/sites/slots/listbackups/action",
    "Microsoft.Web/sites/slots/operationresults/read",
    "Microsoft.Web/sites/slots/operations/read",
    "Microsoft.Web/sites/slots/publish/action",
    "Microsoft.Web/sites/slots/publishxml/action",
    "Microsoft.Web/sites/slots/read",
    "Microsoft.Web/sites/slots/snapshots/read",
    "Microsoft.Web/sites/snapshots/read",
    "Microsoft.Web/staticSites/functions/read",
    "Microsoft.Web/staticSites/read",
    "Microsoft.Web/staticSites/userProvidedFunctionApps/read"
]
}
