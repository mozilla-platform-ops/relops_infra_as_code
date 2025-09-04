locals {
  use_orchestrator_wiz_managed_app = var.wiz_da_orchestrator_wiz_managed_app_id != "00000000-0000-0000-0000-000000000000" ? true : false
  # If multi_tenancy_enabled is true -> "AzureADMultipleOrgs", else "AzureADMyOrg"
  sign_in_aud                              = (var.multi_tenancy_enabled ? "AzureADMultipleOrgs" : "AzureADMyOrg")
  wiz_da_worker_principal_id               = var.use_worker_managed_identity ? azurerm_user_assigned_identity.wiz_da_worker_identity[0].principal_id : azuread_service_principal.wiz_da_worker_sp[0].object_id
  wiz_da_scanner_pass                      = (var.wiz_da_scanner_app_secret == "wiz_auto_create_secret" ? azuread_application_password.wiz_da_scanner_pass.value : var.wiz_da_scanner_app_secret)
  wiz_da_worker_pass                       = (var.wiz_da_worker_app_secret == "wiz_auto_create_secret" && !var.use_worker_managed_identity ? azuread_application_password.wiz_da_worker_pass[0].value : var.wiz_da_worker_app_secret)
  create_scanner_app_key_vault_certificate = var.scanner_app_key_vault_certificate_pem_file_path == null
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

data "azuread_client_config" "current" {}

resource "azuread_application" "wiz_da_orchestrator" {
  count            = local.use_orchestrator_wiz_managed_app ? 0 : 1
  display_name     = var.wiz_da_orchestrator_app_name
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"
  api {
    requested_access_token_version = 2
  }
  web {
    homepage_url = "https://app.wiz.io"
  }

  feature_tags {
    custom_single_sign_on = false
    enterprise            = false
    gallery               = false
    hide                  = false
  }
}

resource "azuread_application_password" "wiz_da_orchestrator_pass" {
  count          = local.use_orchestrator_wiz_managed_app ? 0 : 1
  display_name   = "Wiz Disk Analyzer - Orchestrator"
  application_id = azuread_application.wiz_da_orchestrator[count.index].id
  end_date       = timeadd(formatdate("YYYY-MM-DD'T'00:00:00Z", timestamp()), var.key_expire_end_date_relative) # 24h * 365 days * 10 years
}

resource "azuread_service_principal" "wiz_da_orchestrator_sp" {
  client_id                    = local.use_orchestrator_wiz_managed_app ? var.wiz_da_orchestrator_wiz_managed_app_id : azuread_application.wiz_da_orchestrator[0].client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
  feature_tags {
    custom_single_sign_on = false
    enterprise            = false
    gallery               = false
    hide                  = false
  }
  use_existing = true
}

resource "azuread_application" "wiz_da_scanner" {
  display_name     = var.wiz_da_scanner_app_name
  sign_in_audience = local.sign_in_aud
  owners           = [data.azuread_client_config.current.object_id]
  api {
    requested_access_token_version = 2
  }
  web {
    homepage_url = "https://app.wiz.io"
  }

  feature_tags {
    custom_single_sign_on = false
    enterprise            = false
    gallery               = false
    hide                  = false
  }
}

resource "azuread_application_password" "wiz_da_scanner_pass" {
  display_name   = "Wiz Disk Analyzer - Scanner"
  application_id = azuread_application.wiz_da_scanner.id
  end_date       = timeadd(formatdate("YYYY-MM-DD'T'00:00:00Z", timestamp()), var.key_expire_end_date_relative) # 24h * 365 days * 10 years
}

resource "azuread_service_principal" "wiz_da_scanner_sp" {
  client_id                    = azuread_application.wiz_da_scanner.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
  feature_tags {
    custom_single_sign_on = false
    enterprise            = false
    gallery               = false
    hide                  = false
  }
}

resource "azurerm_user_assigned_identity" "wiz_da_control_plane_identity" {
  count               = var.use_worker_managed_identity ? 1 : 0
  name                = var.wiz_da_control_plane_identity_name
  location            = azurerm_resource_group.wiz_orchestrator_rg.location
  resource_group_name = azurerm_resource_group.wiz_orchestrator_rg.name
}

resource "azuread_application" "wiz_da_worker" {
  count            = var.use_worker_managed_identity ? 0 : 1
  display_name     = var.wiz_da_worker_app_name
  sign_in_audience = "AzureADMyOrg"
  owners           = [data.azuread_client_config.current.object_id]
  api {
    requested_access_token_version = 2
  }
  web {
    homepage_url = "https://app.wiz.io"
  }

  feature_tags {
    custom_single_sign_on = false
    enterprise            = false
    gallery               = false
    hide                  = false
  }
}

resource "azuread_application_password" "wiz_da_worker_pass" {
  count          = var.use_worker_managed_identity ? 0 : 1
  display_name   = "Wiz Disk Analyzer - Worker"
  application_id = azuread_application.wiz_da_worker[count.index].id
  end_date       = timeadd(formatdate("YYYY-MM-DD'T'00:00:00Z", timestamp()), var.key_expire_end_date_relative) # 24h * 365 days * 10 years
}

resource "azuread_service_principal" "wiz_da_worker_sp" {
  count                        = var.use_worker_managed_identity ? 0 : 1
  client_id                    = azuread_application.wiz_da_worker[count.index].client_id
  owners                       = [data.azuread_client_config.current.object_id]
  app_role_assignment_required = false
  feature_tags {
    custom_single_sign_on = false
    enterprise            = false
    gallery               = false
    hide                  = false
  }
}

resource "azurerm_user_assigned_identity" "wiz_da_worker_identity" {
  count               = var.use_worker_managed_identity ? 1 : 0
  name                = var.wiz_da_worker_identity_name
  location            = azurerm_resource_group.wiz_orchestrator_rg.location
  resource_group_name = azurerm_resource_group.wiz_orchestrator_rg.name
}

resource "azurerm_resource_group" "wiz_orchestrator_rg" {
  name     = var.wiz_global_orchestrator_rg_name
  location = var.wiz_global_orchestrator_rg_region
  tags = {
    "owner_email" = "infrastructuresecurity@mozilla.com"
  }
}
# The key vault used by wiz to store app keys
resource "azurerm_key_vault" "wiz_outpost_keyvault" {
  name                            = var.wiz_application_keyvault_name
  location                        = azurerm_resource_group.wiz_orchestrator_rg.location
  resource_group_name             = azurerm_resource_group.wiz_orchestrator_rg.name
  tenant_id                       = var.azure_tenant_id
  enabled_for_disk_encryption     = false
  soft_delete_retention_days      = 90
  purge_protection_enabled        = false
  enable_rbac_authorization       = false
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  sku_name                        = "standard"

  # A policy for the entity calling the terraform to put keys/etc
  access_policy {
    tenant_id               = var.azure_tenant_id
    object_id               = data.azurerm_client_config.current.object_id
    key_permissions         = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
    secret_permissions      = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
    certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
    storage_permissions     = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"]
  }
  # Access for the Wiz Disk Analyzer - Orchestrator app
  access_policy {
    tenant_id          = var.azure_tenant_id
    object_id          = azuread_service_principal.wiz_da_orchestrator_sp.object_id
    key_permissions    = ["Update", "Create", "List", "Get", "Delete"]
    secret_permissions = ["Set", "List", "Get", "Delete"]
  }
  # Access for the Wiz Disk Analyzer - Worker app
  access_policy {
    tenant_id               = var.azure_tenant_id
    object_id               = local.wiz_da_worker_principal_id
    key_permissions         = ["Get", "List", "Sign"]
    secret_permissions      = ["Get", "List"]
    certificate_permissions = ["Get", "List"]
  }

  public_network_access_enabled = true
  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
  tags = {
    "owner_email" = "infrastructuresecurity@mozilla.com"
  }
}

# Write the Wiz Disk Analyzer - Scanner app secret to the key vault
resource "azurerm_key_vault_secret" "wiz_da_scanner_secret" {
  name         = azuread_application.wiz_da_scanner.client_id
  value        = jsonencode({ "tenantId" = var.azure_tenant_id, "clientId" = azuread_application.wiz_da_scanner.client_id, "secretId" = local.wiz_da_scanner_pass })
  key_vault_id = azurerm_key_vault.wiz_outpost_keyvault.id
  tags = {
    "app-name" = var.wiz_da_scanner_app_name
    "file-encoding" : "utf-8"
  }
}

# Create/Import the Wiz Disk Analyzer - Scanner app certificate to the key vault
resource "azurerm_key_vault_certificate" "wiz_da_scanner_certificate" {
  name         = "${azuread_application.wiz_da_scanner.client_id}-certificate"
  key_vault_id = azurerm_key_vault.wiz_outpost_keyvault.id

  dynamic "certificate_policy" {
    for_each = local.create_scanner_app_key_vault_certificate ? [0] : []
    content {
      issuer_parameters {
        name = "Self"
      }
      x509_certificate_properties {
        subject            = "CN=${azuread_application.wiz_da_scanner.client_id}.wiz.io"
        key_usage          = ["cRLSign", "digitalSignature", "keyEncipherment", "keyAgreement", "keyCertSign"]
        validity_in_months = 12
      }
      key_properties {
        exportable = false
        key_type   = "RSA"
        reuse_key  = false
        key_size   = 4096
      }
      secret_properties {
        content_type = "application/x-pkcs12"
      }
    }
  }

  dynamic "certificate" {
    for_each = local.create_scanner_app_key_vault_certificate ? [] : [0]
    content {
      contents = file(var.scanner_app_key_vault_certificate_pem_file_path)
    }
  }

  depends_on = [
    azurerm_key_vault.wiz_outpost_keyvault,
  ]
}

resource "azuread_application_certificate" "wiz_da_scanner_certificate" {
  application_id = format("/applications/%s", azuread_application.wiz_da_scanner.object_id)
  type           = "AsymmetricX509Cert"
  value          = azurerm_key_vault_certificate.wiz_da_scanner_certificate.certificate_data_base64
  encoding       = "pem"
}

# Write the Wiz Disk Analyzer - Worker app secret to the key vault
resource "azurerm_key_vault_secret" "wiz_da_worker_secret" {
  count        = var.use_worker_managed_identity ? 0 : 1
  name         = azuread_application.wiz_da_worker[count.index].client_id
  key_vault_id = azurerm_key_vault.wiz_outpost_keyvault.id
  value        = jsonencode({ "tenantId" = var.azure_tenant_id, "clientId" = azuread_application.wiz_da_worker[count.index].client_id, "secretId" = local.wiz_da_worker_pass })
  tags = {
    "app-name" : var.wiz_da_worker_app_name
    "file-encoding" : "utf-8"
  }
}

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

resource "time_sleep" "wait_for_az_dataplane" {
  create_duration = var.azure_wait_timer
  depends_on = [
    azurerm_role_definition.wiz_diskanalyzer_diskcopy_role,
    azurerm_role_definition.wiz_orchestrator_role,
    azurerm_role_definition.wiz_orchestrator_role_byon,
    azurerm_role_definition.wiz_orch_diskanalyzer_diskmanager_role,
  ]
}

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

resource "azurerm_role_assignment" "wiz_da_scanner_azure_wiz_da_diskcopy_assign" {
  depends_on           = [time_sleep.wait_for_az_dataplane]
  scope                = "/subscriptions/${var.azure_subscription_id}"
  principal_id         = azuread_service_principal.wiz_da_scanner_sp.object_id
  role_definition_name = azurerm_role_definition.wiz_diskanalyzer_diskcopy_role.name
}

resource "azurerm_role_assignment" "wiz_da_scanner_wiz_da_datascanning_copy_assign" {
  count                = (var.enable_data_scanning) ? 1 : 0
  depends_on           = [time_sleep.wait_for_az_dataplane]
  scope                = "/subscriptions/${var.azure_subscription_id}"
  principal_id         = azuread_service_principal.wiz_da_scanner_sp.object_id
  role_definition_name = azurerm_role_definition.wiz_diskanalyzer_datascanning_copy_role[count.index].name
}

resource "azurerm_role_assignment" "wiz_da_control_plane_managed_id_operator_assign" {
  count                = var.use_worker_managed_identity ? 1 : 0
  scope                = azurerm_user_assigned_identity.wiz_da_worker_identity[0].id
  principal_id         = azurerm_user_assigned_identity.wiz_da_control_plane_identity[0].principal_id
  role_definition_name = "Managed Identity Operator"
}

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

resource "azurerm_role_assignment" "wiz_da_worker_wiz_da_datascanning_assign" {
  count                = (var.enable_data_scanning) ? 1 : 0
  depends_on           = [time_sleep.wait_for_az_dataplane]
  scope                = "/subscriptions/${var.azure_subscription_id}"
  principal_id         = local.wiz_da_worker_principal_id
  role_definition_name = azurerm_role_definition.wiz_diskanalyzer_datascanning_role[count.index].name
}
