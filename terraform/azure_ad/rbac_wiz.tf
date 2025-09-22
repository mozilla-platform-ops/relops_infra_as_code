locals {

  NON_FXCI_WIZ_PERMISSIONS = [
    "Microsoft.Sql/locations/capabilities/read",
    "Microsoft.Sql/servers/databases/read",
    "Microsoft.Sql/servers/databases/usages/read",
    "Microsoft.Sql/servers/databases/write",
    "Microsoft.Sql/servers/read",
    "Microsoft.Storage/storageAccounts/inventoryPolicies/write",
    "Microsoft.Storage/storageAccounts/privateEndpointConnections/read",
    "Microsoft.Storage/storageAccounts/privateEndpointConnections/write",
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
    "Microsoft.authorization/locks/read",
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

  FXCI_WIZ_PERMISSIONS = [
    "Microsoft.Compute/galleries/images/versions/read",
    "Microsoft.ContainerRegistry/registries/pull/read",
    "Microsoft.KeyVault/vaults/privateEndpointConnections/read",
    "Microsoft.KeyVault/vaults/privateEndpointConnections/write",
    "Microsoft.Resources/subscriptions/read",
    "Microsoft.authorization/locks/read",
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

  non_fxci_subscriptions_map = {
    "Mozilla Monitor"                 = "36c94cc5-8e6d-49db-a034-bb82b6a2632e",
    "Taskcluster Engineering DevTest" = "8a205152-b25a-417f-a676-80465535a6c9"
    "Firefox_non_CI_DevTest"          = "0a420ff9-bc77-4475-befc-a05071fc92ec"
  }
  fxci_subscriptions_map = {
    "FXCI Azure DevTest"         = "108d46d5-fe9b-4850-9a7d-8c914aa6c1f0",
    "Trusted FXCI Azure DevTest" = "a30e97ab-734a-4f3b-a0e4-c51c0bff0701"
  }
}

# Data source to lookup app registration by client ID
data "azuread_application" "wiz_app" {
  client_id = "6c5e1396-8315-42e8-94a5-1b714e70189b"
}

# Data source to get the service principal for the app registration
data "azuread_service_principal" "wiz_sp" {
  client_id = data.azuread_application.wiz_app.client_id
}

# Data source to get the service principal for the app registration
data "azuread_service_principal" "wiz_enterprise_app_sp" {
  object_id =  "bc7a1764-1e44-48d6-8990-718a2be1ba34"
}

# Assign reader to all subscriptions
resource "azurerm_role_assignment" "wiz_disk_reader" {
  for_each             = merge(local.fxci_subscriptions_map, local.non_fxci_subscriptions_map)
  scope                = "/subscriptions/${each.value}"
  role_definition_name = "Reader"
  principal_id         = data.azuread_service_principal.wiz_sp.object_id
}

# Assign reader to all subscriptions
resource "azurerm_role_assignment" "wiz_enterprise_app_reader" {
  for_each             = toset([
    "Reader",
    "Storage Blob Data Reader",
    "Storage File Data Privileged Reader",
    "Azure Kubernetes Service Cluster User Role",
    "Azure Kubernetes Service RBAC Reader"
  ])
  scope                = "/providers/Microsoft.Management/managementGroups/c0dc8bb0-b616-427e-8217-9513964a145b"
  role_definition_name = each.value
  principal_id         = data.azuread_service_principal.wiz_enterprise_app_sp.object_id
}

# Role definitions for non-FXCI subscriptions (subscription-scoped)
resource "azurerm_role_definition" "wiz_disk_non_fxci" {
  for_each    = local.non_fxci_subscriptions_map
  name        = "WizDiskAnalyzerRole-${each.value}" # Use full subscription ID for uniqueness
  scope       = "/subscriptions/${each.value}"
  description = "Wiz DiskAnalyzer Role for Subscription ${each.key}"
  permissions {
    actions = local.NON_FXCI_WIZ_PERMISSIONS
  }
}

# Role definitions for FXCI subscriptions (subscription-scoped)
resource "azurerm_role_definition" "wiz_disk_fxci" {
  for_each    = local.fxci_subscriptions_map
  name        = "WizDiskAnalyzerRole-${each.value}" # Use full subscription ID for uniqueness
  scope       = "/subscriptions/${each.value}"
  description = "Wiz DiskAnalyzer Role for Subscription ${each.key}"
  permissions {
    actions = local.FXCI_WIZ_PERMISSIONS
  }
}

# Assign FXCI role to FXCI subscriptions
resource "azurerm_role_assignment" "wiz_disk_fxci" {
  for_each           = local.fxci_subscriptions_map
  scope              = "/subscriptions/${each.value}"
  principal_id       = data.azuread_service_principal.wiz_sp.object_id
  role_definition_id = azurerm_role_definition.wiz_disk_fxci[each.key].role_definition_resource_id
}

# Assign non-FXCI role to non-FXCI subscriptions
resource "azurerm_role_assignment" "wiz_disk_non_fxci" {
  for_each           = local.non_fxci_subscriptions_map
  scope              = "/subscriptions/${each.value}"
  principal_id       = data.azuread_service_principal.wiz_sp.object_id
  role_definition_id = azurerm_role_definition.wiz_disk_non_fxci[each.key].role_definition_resource_id
}
