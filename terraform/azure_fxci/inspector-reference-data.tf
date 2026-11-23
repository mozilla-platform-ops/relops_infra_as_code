provider "azurerm" {
  alias           = "inspector_reference_data"
  subscription_id = "108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"
  tenant_id       = local.tenant_id

  features {
    storage {
      data_plane_available = false
    }
  }
}

resource "azurerm_resource_group" "inspector_reference_data" {
  name     = "rg-${local.locationshort}-inspector-reference-data"
  location = local.location
  tags     = local.common_tags
}

resource "azurerm_storage_account" "inspector_reference_data" {
  provider                        = azurerm.inspector_reference_data
  name                            = "safxciinspectordata"
  resource_group_name             = azurerm_resource_group.inspector_reference_data.name
  location                        = azurerm_resource_group.inspector_reference_data.location
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = true
  shared_access_key_enabled       = false
  tags                            = local.common_tags
}

resource "azurerm_storage_container" "inspector_reference_data" {
  name                  = "reference-data"
  storage_account_id    = azurerm_storage_account.inspector_reference_data.id
  container_access_type = "blob"
}

resource "azurerm_storage_management_policy" "inspector_reference_data" {
  storage_account_id = azurerm_storage_account.inspector_reference_data.id

  dynamic "rule" {
    for_each = {
      "worker-pools"         = 3
      "spot-prices/daily"    = 7
      "spot-prices/averages" = 548
    }

    content {
      name    = replace(rule.key, "/", "-")
      enabled = true

      filters {
        prefix_match = ["${azurerm_storage_container.inspector_reference_data.name}/${rule.key}/"]
        blob_types   = ["blockBlob"]
      }

      actions {
        base_blob {
          delete_after_days_since_modification_greater_than = rule.value
        }
      }
    }
  }
}

resource "azurerm_user_assigned_identity" "inspector_reference_data" {
  name                = "id-inspector-reference-data"
  resource_group_name = azurerm_resource_group.inspector_reference_data.name
  location            = azurerm_resource_group.inspector_reference_data.location
  tags                = local.common_tags
}

resource "azurerm_federated_identity_credential" "inspector_reference_data" {
  name                      = "github-try-cost-inspector-main"
  user_assigned_identity_id = azurerm_user_assigned_identity.inspector_reference_data.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = "https://token.actions.githubusercontent.com"
  subject                   = "repo:mozilla-platform-ops/try-cost-inspector:ref:refs/heads/main"
}

resource "azurerm_role_assignment" "inspector_reference_data" {
  scope                            = azurerm_storage_container.inspector_reference_data.id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = azurerm_user_assigned_identity.inspector_reference_data.principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

output "inspector_reference_data" {
  description = "Azure OIDC and storage settings for the try-cost-inspector reference data publishers."
  value = {
    client_id         = azurerm_user_assigned_identity.inspector_reference_data.client_id
    storage_account   = azurerm_storage_account.inspector_reference_data.name
    storage_container = azurerm_storage_container.inspector_reference_data.name
    public_base_url   = "${azurerm_storage_account.inspector_reference_data.primary_blob_endpoint}${azurerm_storage_container.inspector_reference_data.name}/"
  }
}
