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
}

# Data source to lookup app registration by client ID
data "azuread_application" "wiz_app" {
  client_id = "6c5e1396-8315-42e8-94a5-1b714e70189b"
}

# Data source to get the service principal for the app registration
data "azuread_service_principal" "wiz_sp" {
  client_id = data.azuread_application.wiz_app.client_id
}

resource "azurerm_role_definition" "wiz_disk_non_fxci" {
  for_each = [
    "/subscriptions/36c94cc5-8e6d-49db-a034-bb82b6a2632e", ## Mozilla Monitor
    "/subscriptions/8a205152-b25a-417f-a676-80465535a6c9", ## Taskcluster Engineering DevTest
    "/subscriptions/0a420ff9-bc77-4475-befc-a05071fc92ec"  ## Firefox non-CI DevTest
  ]
  name        = "WizDiskAnalyzerRole"
  scope       = each.value
  description = "Wiz DiskAnalyzer Role"
  permissions {
    actions = local.NON_FXCI_WIZ_PERMISSIONS
  }
}

resource "azurerm_role_definition" "wiz_disk_fxci" {
  for_each = [
    "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0", ## FXCI Azure DevTest
    "/subscriptions/a30e97ab-734a-4f3b-a0e4-c51c0bff0701"  ## Trusted FXCI Azure DevTest
  ]
  name        = "FXCI_WizDiskAnalyzerRole"
  scope       = each.value
  description = "Wiz DiskAnalyzer Role for FXCI Subscriptions"
  permissions {
    actions = local.FXCI_WIZ_PERMISSIONS
  }
}

resource "azurerm_role_assignment" "wiz_disk_fxci" {
  for_each = [
    "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0", ## FXCI Azure DevTest
    "/subscriptions/a30e97ab-734a-4f3b-a0e4-c51c0bff0701"  ## Trusted FXCI Azure DevTest
  ]
  scope                = each.value
  principal_id         = data.azuread_service_principal.wiz_da_orchestrator_sp.object_id
  role_definition_name = azurerm_role_definition.wiz_disk_fxci.name
}

resource "azurerm_role_assignment" "wiz_disk_non_fxci" {
  for_each = [
    "/subscriptions/36c94cc5-8e6d-49db-a034-bb82b6a2632e", ## Mozilla Monitor
    "/subscriptions/8a205152-b25a-417f-a676-80465535a6c9", ## Taskcluster Engineering DevTest
    "/subscriptions/0a420ff9-bc77-4475-befc-a05071fc92ec"  ## Firefox non-CI DevTest
  ]
  scope                = each.value
  principal_id         = data.azuread_service_principal.wiz_da_orchestrator_sp.object_id
  role_definition_name = azurerm_role_definition.wiz_disk_non_fxci.name
}
