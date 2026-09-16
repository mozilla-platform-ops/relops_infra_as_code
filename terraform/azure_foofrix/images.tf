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
    platform_performance = {
      id   = data.azuread_group.platform_performance.object_id
      type = "Group"
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

resource "azurerm_shared_image" "windows" {
  name                = "win11_64_24h2"
  gallery_name        = azurerm_shared_image_gallery.foofrix.name
  resource_group_name = azurerm_resource_group.foofrix.name
  location            = local.location
  os_type             = "Windows"
  architecture        = "x64"
  hyper_v_generation  = "V2"
  specialized         = false
  tags                = local.common_tags

  identifier {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-24h2-avd"
  }
}

data "azuread_service_principal" "foofrix_image_build" {
  display_name = "sp-foofrix-image-build"
}

resource "azurerm_resource_group" "image_build" {
  name     = "rg-foofrix-image-build"
  location = local.location
  tags     = local.common_tags
}

# Packer uses the build resource group's location for its temporary VM.
resource "azurerm_resource_group" "image_build_westus3" {
  name     = "rg-foofrix-image-build-westus3"
  location = "westus3"
  tags     = local.common_tags
}

resource "azurerm_user_assigned_identity" "image_build" {
  name                = "id-foofrix-image-build"
  resource_group_name = azurerm_resource_group.foofrix.name
  location            = local.location
  tags                = local.common_tags

  depends_on = [azurerm_resource_provider_registration.this["Microsoft.ManagedIdentity"]]
}

resource "azurerm_role_assignment" "image_build_contributor" {
  for_each = {
    build         = azurerm_resource_group.image_build.id
    build_westus3 = azurerm_resource_group.image_build_westus3.id
    gallery       = azurerm_shared_image_gallery.foofrix.id
  }
  scope                            = each.value
  role_definition_name             = "Contributor"
  principal_id                     = data.azuread_service_principal.foofrix_image_build.object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "image_build_identity_operator" {
  scope                            = azurerm_user_assigned_identity.image_build.id
  role_definition_name             = "Managed Identity Operator"
  principal_id                     = data.azuread_service_principal.foofrix_image_build.object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "image_build_blob_reader" {
  for_each = {
    builder = data.azuread_service_principal.foofrix_image_build.object_id
    guest   = azurerm_user_assigned_identity.image_build.principal_id
  }
  scope                            = azurerm_storage_container.artifacts.id
  role_definition_name             = "Storage Blob Data Reader"
  principal_id                     = each.value
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
