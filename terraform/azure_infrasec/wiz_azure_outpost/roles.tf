/*
=================================================
WIZ CUSTOM ROLE DEFINITIONS
=================================================
*/

# The Wiz Orchestrator Role with Automated Outpost
resource "azurerm_role_definition" "wiz_orchestrator_role" {
  count       = var.self-managed-network ? 0 : 1
  name        = var.wiz_custom_orchestrator_role_name
  scope       = "/subscriptions/${var.azure_subscription_id}"
  description = "Wiz DiskAnalyzer Orchestrator Role"

  permissions {
    actions          = local.ORCHESTRATOR_CUSTOM_ROLE_ACTIONS
    not_actions      = []
    data_actions     = local.ORCHESTRATOR_CUSTOM_ROLE_DATA_ACTIONS
    not_data_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${var.azure_subscription_id}"
  ]
}

# The Wiz Orchestrator Role with BYON
resource "azurerm_role_definition" "wiz_orchestrator_role_byon" {
  count       = var.self-managed-network ? 1 : 0
  name        = var.wiz_custom_orchestrator_role_name
  scope       = "/subscriptions/${var.azure_subscription_id}"
  description = "Wiz DiskAnalyzer Orchestrator Role"

  permissions {
    actions          = local.ORCHESTRATOR_BYON_CUSTOM_ROLE_ACTIONS
    not_actions      = []
    data_actions     = local.ORCHESTRATOR_CUSTOM_ROLE_DATA_ACTIONS
    not_data_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${var.azure_subscription_id}"
  ]
}


# Wiz Diskanalyzer Diskmanager Role
resource "azurerm_role_definition" "wiz_orch_diskanalyzer_diskmanager_role" {
  name        = var.wiz_custom_orch_disk_manager_worker_role_name
  scope       = "/subscriptions/${var.azure_subscription_id}"
  description = "Wiz DiskAnalyzer DiskManager Role"

  permissions {
    actions          = local.DISK_MANAGER_CUSTOM_ROLE_ACTIONS
    not_actions      = []
    data_actions     = []
    not_data_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${var.azure_subscription_id}"
  ]
}

# Wiz Diskanalyzer Diskcopy role
resource "azurerm_role_definition" "wiz_diskanalyzer_diskcopy_role" {
  name        = var.wiz_custom_disk_copy_role_name
  scope       = "/subscriptions/${var.azure_subscription_id}"
  description = "Wiz DiskAnalyzer DiskCopy Role"

  permissions {
    actions          = local.DISK_COPY_CUSTOM_ROLE_ACTIONS
    not_actions      = []
    data_actions     = []
    not_data_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${var.azure_subscription_id}"
  ]
}

# Wiz Diskanalyzer Datascanning role
resource "azurerm_role_definition" "wiz_diskanalyzer_datascanning_role" {
  # Create this resource only if enable_data_scanning is `true` - default `false`
  count       = (var.enable_data_scanning) ? 1 : 0
  name        = var.wiz_custom_data_scanning_role_name
  scope       = "/subscriptions/${var.azure_subscription_id}"
  description = "Wiz DiskAnalyzer Data Scanning Role"

  permissions {
    actions          = local.DATA_SCANNING_CUSTOM_ROLE_ACTIONS
    not_actions      = []
    data_actions     = []
    not_data_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${var.azure_subscription_id}"
  ]
}

# Wiz Diskanalyzer Datascanning Copy role
resource "azurerm_role_definition" "wiz_diskanalyzer_datascanning_copy_role" {
  count       = (var.enable_data_scanning) ? 1 : 0
  name        = var.wiz_custom_data_scanning_copy_role_name
  scope       = "/subscriptions/${var.azure_subscription_id}"
  description = "Wiz DiskAnalyzer Data Scanning Copy Role"

  permissions {
    actions          = local.DATA_SCANNING_COPY_ROLE_ACTIONS
    not_actions      = []
    data_actions     = []
    not_data_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${var.azure_subscription_id}"
  ]
}

/*
=================================================
ARTIFICIAL WAIT TIMER - AZ DATAPLANE PROPAGATION
=================================================
*/

# We add a wait condition here because the custom role can take time to propagate
# In Azure and may not immediately be available to return results for the policy attachment
# Using a depends_on at the resource level for the attachment is not as relaible as a simple wait condition

resource "time_sleep" "wait_for_az_dataplane" {
  create_duration = var.azure_wait_timer
  depends_on = [
    azurerm_role_definition.wiz_diskanalyzer_diskcopy_role,
    azurerm_role_definition.wiz_orchestrator_role,
    azurerm_role_definition.wiz_orchestrator_role_byon,
    azurerm_role_definition.wiz_orch_diskanalyzer_diskmanager_role,
  ]
}

/*
=================================================
WIZ ROLE ASSIGNMENTS - DA ORCHESTRATOR
=================================================
*/

resource "azurerm_role_assignment" "wiz_da_orchestrator_wiz_orch_assign" {
  depends_on           = [time_sleep.wait_for_az_dataplane]
  count                = var.self-managed-network ? 0 : 1
  scope                = "/subscriptions/${var.azure_subscription_id}"
  principal_id         = azuread_service_principal.wiz_da_orchestrator_sp.object_id
  role_definition_name = azurerm_role_definition.wiz_orchestrator_role[0].name
}

resource "azurerm_role_assignment" "wiz_da_orchestrator_wiz_orch_assign_byon" {
  depends_on           = [time_sleep.wait_for_az_dataplane]
  count                = var.self-managed-network ? 1 : 0
  scope                = "/subscriptions/${var.azure_subscription_id}"
  principal_id         = azuread_service_principal.wiz_da_orchestrator_sp.object_id
  role_definition_name = azurerm_role_definition.wiz_orchestrator_role_byon[0].name
}

resource "azurerm_role_assignment" "wiz_da_orchestrator_managed_id_operator_assign" {
  count                = var.use_worker_managed_identity ? 1 : 0
  scope                = azurerm_user_assigned_identity.wiz_da_control_plane_identity[0].id
  principal_id         = azuread_service_principal.wiz_da_orchestrator_sp.object_id
  role_definition_name = "Managed Identity Operator"
}

/*
=================================================
WIZ ROLE ASSIGNMENTS - DA SCANNER
=================================================
*/

resource "azurerm_role_assignment" "wiz_da_scanner_azure_wiz_da_diskcopy_assign" {
  depends_on           = [time_sleep.wait_for_az_dataplane]
  scope                = "/subscriptions/${var.azure_subscription_id}"
  principal_id         = azuread_service_principal.wiz_da_scanner_sp.object_id
  role_definition_name = azurerm_role_definition.wiz_diskanalyzer_diskcopy_role.name
}

# Optionally assign the Wiz DiskAnalyzer Data Scanning Copy Role Wiz Disk Analyzer - Scanner app
# If enable_data_scanning is true
resource "azurerm_role_assignment" "wiz_da_scanner_wiz_da_datascanning_copy_assign" {
  count                = (var.enable_data_scanning) ? 1 : 0
  depends_on           = [time_sleep.wait_for_az_dataplane]
  scope                = "/subscriptions/${var.azure_subscription_id}"
  principal_id         = azuread_service_principal.wiz_da_scanner_sp.object_id
  role_definition_name = azurerm_role_definition.wiz_diskanalyzer_datascanning_copy_role[count.index].name
}

/*
=================================================
WIZ ROLE ASSIGNMENTS - DA CONTROL PLANE
=================================================
*/

resource "azurerm_role_assignment" "wiz_da_control_plane_managed_id_operator_assign" {
  count                = var.use_worker_managed_identity ? 1 : 0
  scope                = azurerm_user_assigned_identity.wiz_da_worker_identity[0].id
  principal_id         = azurerm_user_assigned_identity.wiz_da_control_plane_identity[0].principal_id
  role_definition_name = "Managed Identity Operator"
}

/*
=================================================
WIZ ROLE ASSIGNMENTS - DA WORKER
=================================================
*/

resource "azurerm_role_assignment" "wiz_da_worker_azure_vm_contributor_assign" {
  scope                = "/subscriptions/${var.azure_subscription_id}"
  principal_id         = local.wiz_da_worker_principal_id
  role_definition_name = "Virtual Machine Contributor"
}

resource "azurerm_role_assignment" "wiz_da_worker_wiz_orch_disk_manager_worker_role_assign" {
  depends_on           = [time_sleep.wait_for_az_dataplane]
  scope                = "/subscriptions/${var.azure_subscription_id}"
  principal_id         = local.wiz_da_worker_principal_id
  role_definition_name = azurerm_role_definition.wiz_orch_diskanalyzer_diskmanager_role.name
}

# Optionally assign the Wiz DiskAnalyzer Data Scanning Role to the Wiz Disk Analyser - Worker app
# If enable_data_scanning is true
resource "azurerm_role_assignment" "wiz_da_worker_wiz_da_datascanning_assign" {
  count                = (var.enable_data_scanning) ? 1 : 0
  depends_on           = [time_sleep.wait_for_az_dataplane]
  scope                = "/subscriptions/${var.azure_subscription_id}"
  principal_id         = local.wiz_da_worker_principal_id
  role_definition_name = azurerm_role_definition.wiz_diskanalyzer_datascanning_role[count.index].name
}

locals {
  ORCHESTRATOR_CUSTOM_ROLE_ACTIONS = [
    "Microsoft.Authorization/*/read",
    "Microsoft.ContainerService/locations/guardrailsVersions/read",
    "Microsoft.ContainerService/managedClusters/accessProfiles/listCredential/action",
    "Microsoft.ContainerService/managedClusters/accessProfiles/read",
    "Microsoft.ContainerService/managedClusters/agentPools/delete",
    "Microsoft.ContainerService/managedClusters/agentPools/read",
    "Microsoft.ContainerService/managedClusters/agentPools/upgradeNodeImageVersion/write",
    "Microsoft.ContainerService/managedClusters/agentPools/upgradeProfiles/read",
    "Microsoft.ContainerService/managedClusters/agentPools/write",
    "Microsoft.ContainerService/managedClusters/availableAgentPoolVersions/read",
    "Microsoft.ContainerService/managedClusters/commandResults/read",
    "Microsoft.ContainerService/managedClusters/delete",
    "Microsoft.ContainerService/managedClusters/detectors/read",
    "Microsoft.ContainerService/managedClusters/diagnosticsState/read",
    "Microsoft.ContainerService/managedClusters/eventGridFilters/delete",
    "Microsoft.ContainerService/managedClusters/eventGridFilters/read",
    "Microsoft.ContainerService/managedClusters/eventGridFilters/write",
    "Microsoft.ContainerService/managedClusters/extensionaddons/delete",
    "Microsoft.ContainerService/managedClusters/extensionaddons/read",
    "Microsoft.ContainerService/managedClusters/extensionaddons/write",
    "Microsoft.ContainerService/managedClusters/listClusterAdminCredential/action",
    "Microsoft.ContainerService/managedClusters/listClusterMonitoringUserCredential/action",
    "Microsoft.ContainerService/managedClusters/listClusterUserCredential/action",
    "Microsoft.ContainerService/managedClusters/maintenanceConfigurations/delete",
    "Microsoft.ContainerService/managedClusters/maintenanceConfigurations/read",
    "Microsoft.ContainerService/managedClusters/maintenanceConfigurations/write",
    "Microsoft.ContainerService/managedClusters/networkSecurityPerimeterAssociationProxies/delete",
    "Microsoft.ContainerService/managedClusters/networkSecurityPerimeterAssociationProxies/read",
    "Microsoft.ContainerService/managedClusters/networkSecurityPerimeterAssociationProxies/write",
    "Microsoft.ContainerService/managedClusters/networkSecurityPerimeterConfigurations/read",
    "Microsoft.ContainerService/managedClusters/privateEndpointConnections/delete",
    "Microsoft.ContainerService/managedClusters/privateEndpointConnections/read",
    "Microsoft.ContainerService/managedClusters/privateEndpointConnections/write",
    "Microsoft.ContainerService/managedClusters/privateEndpointConnectionsApproval/action",
    "Microsoft.ContainerService/managedClusters/providers/Microsoft.Insights/diagnosticSettings/read",
    "Microsoft.ContainerService/managedClusters/providers/Microsoft.Insights/diagnosticSettings/write",
    "Microsoft.ContainerService/managedClusters/providers/Microsoft.Insights/logDefinitions/read",
    "Microsoft.ContainerService/managedClusters/read",
    "Microsoft.ContainerService/managedClusters/resetAADProfile/action",
    "Microsoft.ContainerService/managedClusters/resetServicePrincipalProfile/action",
    "Microsoft.ContainerService/managedClusters/resolvePrivateLinkServiceId/action",
    "Microsoft.ContainerService/managedClusters/rotateClusterCertificates/action",
    "Microsoft.ContainerService/managedClusters/runCommand/action",
    "Microsoft.ContainerService/managedClusters/start/action",
    "Microsoft.ContainerService/managedClusters/stop/action",
    "Microsoft.ContainerService/managedClusters/unpinManagedCluster/action",
    "Microsoft.ContainerService/managedClusters/upgradeProfiles/read",
    "Microsoft.ContainerService/managedClusters/write",
    "Microsoft.Insights/alertRules/*",
    "Microsoft.Insights/diagnosticSettings/*",
    "Microsoft.KeyVault/vaults/PrivateEndpointConnectionsApproval/action",
    "Microsoft.KeyVault/vaults/read",
    "Microsoft.KeyVault/vaults/write",
    "Microsoft.Network/*",
    "Microsoft.Network/virtualNetworks/subnets/joinViaServiceEndpoint/action",
    "Microsoft.ResourceHealth/availabilityStatuses/read",
    "Microsoft.ResourceHealth/availabilityStatuses/read",
    "Microsoft.Resources/deployments/*",
    "Microsoft.Resources/subscriptions/resourceGroups/delete",
    "Microsoft.Resources/subscriptions/resourceGroups/moveResources/action",
    "Microsoft.Resources/subscriptions/resourceGroups/read",
    "Microsoft.Resources/subscriptions/resourceGroups/validateMoveResources/action",
    "Microsoft.Resources/subscriptions/resourceGroups/write",
    "Microsoft.Resources/subscriptions/resourcegroups/deployments/operations/read",
    "Microsoft.Resources/subscriptions/resourcegroups/deployments/operationstatuses/read",
    "Microsoft.Resources/subscriptions/resourcegroups/deployments/read",
    "Microsoft.Resources/subscriptions/resourcegroups/deployments/write",
    "Microsoft.Resources/subscriptions/resourcegroups/resources/read",
    "Microsoft.Storage/storageAccounts/PrivateEndpointConnectionsApproval/action",
    "Microsoft.Storage/storageAccounts/blobServices/containers/clearLegalHold/action",
    "Microsoft.Storage/storageAccounts/blobServices/containers/delete",
    "Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies/delete",
    "Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies/extend/action",
    "Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies/lock/action",
    "Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies/read",
    "Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies/write",
    "Microsoft.Storage/storageAccounts/blobServices/containers/lease/action",
    "Microsoft.Storage/storageAccounts/blobServices/containers/migrate/action",
    "Microsoft.Storage/storageAccounts/blobServices/containers/read",
    "Microsoft.Storage/storageAccounts/blobServices/containers/setLegalHold/action",
    "Microsoft.Storage/storageAccounts/blobServices/containers/write",
    "Microsoft.Storage/storageAccounts/delete",
    "Microsoft.Storage/storageAccounts/listkeys/action",
    "Microsoft.Storage/storageAccounts/read",
    "Microsoft.Storage/storageAccounts/write"
]

  ORCHESTRATOR_BYON_CUSTOM_ROLE_ACTIONS = [
    "Microsoft.ContainerService/locations/guardrailsVersions/read",
    "Microsoft.ContainerService/managedClusters/accessProfiles/listCredential/action",
    "Microsoft.ContainerService/managedClusters/accessProfiles/read",
    "Microsoft.ContainerService/managedClusters/agentPools/delete",
    "Microsoft.ContainerService/managedClusters/agentPools/read",
    "Microsoft.ContainerService/managedClusters/agentPools/upgradeNodeImageVersion/write",
    "Microsoft.ContainerService/managedClusters/agentPools/upgradeProfiles/read",
    "Microsoft.ContainerService/managedClusters/agentPools/write",
    "Microsoft.ContainerService/managedClusters/availableAgentPoolVersions/read",
    "Microsoft.ContainerService/managedClusters/commandResults/read",
    "Microsoft.ContainerService/managedClusters/delete",
    "Microsoft.ContainerService/managedClusters/detectors/read",
    "Microsoft.ContainerService/managedClusters/diagnosticsState/read",
    "Microsoft.ContainerService/managedClusters/eventGridFilters/delete",
    "Microsoft.ContainerService/managedClusters/eventGridFilters/read",
    "Microsoft.ContainerService/managedClusters/eventGridFilters/write",
    "Microsoft.ContainerService/managedClusters/extensionaddons/delete",
    "Microsoft.ContainerService/managedClusters/extensionaddons/read",
    "Microsoft.ContainerService/managedClusters/extensionaddons/write",
    "Microsoft.ContainerService/managedClusters/listClusterAdminCredential/action",
    "Microsoft.ContainerService/managedClusters/listClusterMonitoringUserCredential/action",
    "Microsoft.ContainerService/managedClusters/listClusterUserCredential/action",
    "Microsoft.ContainerService/managedClusters/maintenanceConfigurations/delete",
    "Microsoft.ContainerService/managedClusters/maintenanceConfigurations/read",
    "Microsoft.ContainerService/managedClusters/maintenanceConfigurations/write",
    "Microsoft.ContainerService/managedClusters/networkSecurityPerimeterAssociationProxies/delete",
    "Microsoft.ContainerService/managedClusters/networkSecurityPerimeterAssociationProxies/read",
    "Microsoft.ContainerService/managedClusters/networkSecurityPerimeterAssociationProxies/write",
    "Microsoft.ContainerService/managedClusters/networkSecurityPerimeterConfigurations/read",
    "Microsoft.ContainerService/managedClusters/privateEndpointConnections/delete",
    "Microsoft.ContainerService/managedClusters/privateEndpointConnections/read",
    "Microsoft.ContainerService/managedClusters/privateEndpointConnections/write",
    "Microsoft.ContainerService/managedClusters/privateEndpointConnectionsApproval/action",
    "Microsoft.ContainerService/managedClusters/providers/Microsoft.Insights/logDefinitions/read",
    "Microsoft.ContainerService/managedClusters/read",
    "Microsoft.ContainerService/managedClusters/resetAADProfile/action",
    "Microsoft.ContainerService/managedClusters/resetServicePrincipalProfile/action",
    "Microsoft.ContainerService/managedClusters/resolvePrivateLinkServiceId/action",
    "Microsoft.ContainerService/managedClusters/rotateClusterCertificates/action",
    "Microsoft.ContainerService/managedClusters/runCommand/action",
    "Microsoft.ContainerService/managedClusters/start/action",
    "Microsoft.ContainerService/managedClusters/stop/action",
    "Microsoft.ContainerService/managedClusters/unpinManagedCluster/action",
    "Microsoft.ContainerService/managedClusters/upgradeProfiles/read",
    "Microsoft.ContainerService/managedClusters/write",
    "Microsoft.KeyVault/vaults/PrivateEndpointConnectionsApproval/action",
    "Microsoft.KeyVault/vaults/read",
    "Microsoft.KeyVault/vaults/write",
    "Microsoft.Network/networkInterfaces/read",
    "Microsoft.Network/privateEndpoints/delete",
    "Microsoft.Network/privateEndpoints/read",
    "Microsoft.Network/privateEndpoints/write",
    "Microsoft.Network/virtualNetworks/read",
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Network/virtualNetworks/subnets/joinViaServiceEndpoint/action",
    "Microsoft.ResourceHealth/availabilityStatuses/read",
    "Microsoft.Resources/deployments/cancel/action",
    "Microsoft.Resources/deployments/delete",
    "Microsoft.Resources/deployments/exportTemplate/action",
    "Microsoft.Resources/deployments/operations/read",
    "Microsoft.Resources/deployments/operationstatuses/read",
    "Microsoft.Resources/deployments/read",
    "Microsoft.Resources/deployments/validate/action",
    "Microsoft.Resources/deployments/whatIf/action",
    "Microsoft.Resources/deployments/write",
    "Microsoft.Resources/subscriptions/resourceGroups/read",
    "Microsoft.Resources/subscriptions/resourcegroups/deployments/operations/read",
    "Microsoft.Resources/subscriptions/resourcegroups/deployments/read",
    "Microsoft.Resources/subscriptions/resourcegroups/resources/read",
    "Microsoft.Storage/storageAccounts/PrivateEndpointConnectionsApproval/action",
    "Microsoft.Storage/storageAccounts/blobServices/containers/clearLegalHold/action",
    "Microsoft.Storage/storageAccounts/blobServices/containers/delete",
    "Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies/delete",
    "Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies/extend/action",
    "Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies/lock/action",
    "Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies/read",
    "Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies/write",
    "Microsoft.Storage/storageAccounts/blobServices/containers/lease/action",
    "Microsoft.Storage/storageAccounts/blobServices/containers/migrate/action",
    "Microsoft.Storage/storageAccounts/blobServices/containers/read",
    "Microsoft.Storage/storageAccounts/blobServices/containers/setLegalHold/action",
    "Microsoft.Storage/storageAccounts/blobServices/containers/write",
    "Microsoft.Storage/storageAccounts/delete",
    "Microsoft.Storage/storageAccounts/listkeys/action",
    "Microsoft.Storage/storageAccounts/read",
    "Microsoft.Storage/storageAccounts/write"
]

  ORCHESTRATOR_CUSTOM_ROLE_DATA_ACTIONS = [
    "Microsoft.ContainerService/managedClusters/*"
]

  DISK_MANAGER_CUSTOM_ROLE_ACTIONS = [
    "Microsoft.Compute/diskEncryptionSets/read",
    "Microsoft.Compute/disks/delete",
    "Microsoft.Compute/disks/read",
    "Microsoft.Compute/disks/write",
    "Microsoft.Network/privateEndpoints/delete",
    "Microsoft.Network/privateEndpoints/read",
    "Microsoft.Network/privateEndpoints/write",
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Storage/storageAccounts/listkeys/action"
]

  DISK_COPY_CUSTOM_ROLE_ACTIONS = [
    "Microsoft.Compute/diskEncryptionSets/read",
    "Microsoft.Compute/disks/write"
]

  DATA_SCANNING_CUSTOM_ROLE_ACTIONS = [
    "Microsoft.DocumentDB/databaseAccounts/read",
    "Microsoft.DocumentDB/databaseAccounts/readonlykeys/action",
    "Microsoft.Insights/metrics/read",
    "Microsoft.ManagedIdentity/userAssignedIdentities/assign/action",
    "Microsoft.Network/virtualNetworks/subnets/joinViaServiceEndpoint/action",
    "Microsoft.Sql/servers/databases/azureAsyncOperation/read",
    "Microsoft.Sql/servers/databases/write",
    "Microsoft.Sql/servers/delete",
    "Microsoft.Sql/servers/read",
    "Microsoft.Sql/servers/virtualNetworkRules/write",
    "Microsoft.Sql/servers/write"
]

  DATA_SCANNING_COPY_ROLE_ACTIONS = [
    "Microsoft.ManagedIdentity/userAssignedIdentities/assign/action",
    "Microsoft.Sql/servers/databases/write"
]

}
