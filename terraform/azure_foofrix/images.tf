resource "azurerm_shared_image_gallery" "foofrix" {
  name                = "foofrix"
  resource_group_name = azurerm_resource_group.foofrix.name
  location            = local.location
  description         = "Windows images for FooFrix performance agents."
  tags                = local.common_tags

  depends_on = [azurerm_resource_provider_registration.this["Microsoft.Compute"]]
}

resource "azurerm_storage_account" "foofrix" {
  name                            = "safoofrix${substr(azurerm_subscription.foofrix.subscription_id, 0, 8)}"
  resource_group_name             = azurerm_resource_group.foofrix.name
  location                        = local.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags

  depends_on = [azurerm_resource_provider_registration.this["Microsoft.Storage"]]
}

resource "azurerm_storage_container" "artifacts" {
  name                  = "artifacts"
  storage_account_id    = azurerm_storage_account.foofrix.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "blob_contributor" {
  for_each = {
    provisioner = {
      id   = data.azuread_service_principal.foofrix.object_id
      type = "ServicePrincipal"
    }
    worker = {
      id   = azurerm_user_assigned_identity.worker.principal_id
      type = "ServicePrincipal"
    }
    relops = {
      id   = data.azuread_group.relops.object_id
      type = "Group"
    }
  }

  scope                            = azurerm_storage_container.artifacts.id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = each.value.id
  principal_type                   = each.value.type
  skip_service_principal_aad_check = each.value.type == "ServicePrincipal"
}
