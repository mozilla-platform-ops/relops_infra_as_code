locals {
  # If service_principal_object_id is provided, use it directly
  # Otherwise, use the lookup or creation logic
  azure_ad_sp = var.wiz_app_object_id != "" ? var.wiz_app_object_id : (
    var.use_existing_service_principal ? data.azuread_service_principal.wiz_for_azure[0].object_id : azuread_service_principal.wiz_for_azure[0].object_id
  )
  management_group_id = "/providers/Microsoft.Management/managementGroups/${var.azure_management_group_id}"
  subscription_id     = "/subscriptions/${var.azure_subscription_id}"

  scope        = try(coalesce(var.azure_management_group_id != "" ? local.management_group_id : null, var.azure_subscription_id != "" ? local.subscription_id : null), "")
  scope_exists = length(local.scope) > 0

  entra_id_scanning = var.enable_entra_id_scanning

  application_roles = ["Directory.Read.All", "Policy.Read.All", "RoleManagement.Read.All", "AccessReview.Read.All", "AuditLog.Read.All"]


  WIZ_CUSTOM_ROLE_ACTIONS = [
    "Microsoft.Compute/snapshots/read",
    "Microsoft.ContainerRegistry/registries/webhooks/getCallbackConfig/action",
    "Microsoft.ContainerRegistry/registries/webhooks/listEvents/action",
    "Microsoft.DataFactory/factories/querydataflowdebugsessions/action",
    "Microsoft.HDInsight/clusters/read",
    "Microsoft.Web/sites/config/list/Action",
    "Microsoft.Web/sites/slots/config/list/Action"
  ]
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

resource "azuread_service_principal" "wiz_for_azure" {
  count     = var.use_existing_service_principal ? 0 : 1
  client_id = var.wiz_app_id
}

resource "azuread_service_principal" "msgraph" {
  # If entra_id_scanning is true, create the Wiz for Azure service principal
  count        = local.entra_id_scanning ? 1 : 0
  client_id    = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing = true
}

resource "azuread_app_role_assignment" "sp_grant_role_consent" {
  # If entra_id_scanning is true, grant the Wiz for Azure service principal the required permissions to read the Microsoft Graph
  count               = local.entra_id_scanning && !var.use_existing_service_principal ? length(local.application_roles) : 0
  app_role_id         = azuread_service_principal.msgraph[0].app_role_ids[local.application_roles[count.index]]
  principal_object_id = local.azure_ad_sp
  resource_object_id  = azuread_service_principal.msgraph[0].object_id

  depends_on = [
    azuread_service_principal.msgraph
  ]
}

# Create Wiz Custom Role for Wiz for Azure app
resource "azurerm_role_definition" "wiz_custom_role" {
  name  = var.wiz_custom_role_name
  scope = local.scope
  count = local.scope_exists ? 1 : 0

  description = "Wiz Custom Role"

  permissions {
    actions = concat(
      local.WIZ_CUSTOM_ROLE_ACTIONS
    )
  }

  assignable_scopes = [local.scope]
}

resource "time_sleep" "wait_for_azure_dataplane_custom_role" {
  depends_on      = [azurerm_role_definition.wiz_custom_role]
  count           = local.scope_exists ? 1 : 0
  create_duration = var.azure_wait_timer
}

resource "azurerm_role_assignment" "wiz_custom_role_assignment" {
  scope                = local.scope
  count                = local.scope_exists ? 1 : 0
  principal_id         = local.azure_ad_sp
  role_definition_name = var.wiz_custom_role_name
  depends_on           = [time_sleep.wait_for_azure_dataplane_custom_role]
}

# Assign Wiz for Azure app to built-in roles
resource "azurerm_role_assignment" "wiz_k8s_cluster_role_assignment" {
  scope                = local.scope
  count                = local.scope_exists ? 1 : 0
  principal_id         = local.azure_ad_sp
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
}

resource "azurerm_role_assignment" "wiz_k8s_rbac_role_assignment" {
  scope                = local.scope
  count                = local.scope_exists ? 1 : 0
  principal_id         = local.azure_ad_sp
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
}

resource "azurerm_role_assignment" "wiz_reader_role_assignment" {
  scope                = local.scope
  count                = local.scope_exists ? 1 : 0
  principal_id         = local.azure_ad_sp
  role_definition_name = "Reader"
}

resource "azurerm_role_assignment" "wiz_openai_role_assignment" {
  scope                = local.scope
  count                = local.scope_exists && var.enable_openai_scanning ? 1 : 0
  principal_id         = local.azure_ad_sp
  role_definition_name = "Cognitive Services OpenAI User"
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