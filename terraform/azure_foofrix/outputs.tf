output "subscription_id" {
  value = azurerm_subscription.foofrix.subscription_id
}

output "provisioner_client_id" {
  value = data.azuread_service_principal.foofrix.client_id
}

output "worker_identity_id" {
  value = azurerm_user_assigned_identity.worker.id
}

output "worker_identity_client_id" {
  value = azurerm_user_assigned_identity.worker.client_id
}

output "key_vault_uri" {
  value = azurerm_key_vault.foofrix.vault_uri
}

output "image_gallery_id" {
  value = azurerm_shared_image_gallery.foofrix.id
}

output "artifacts_container_url" {
  value = "${azurerm_storage_account.foofrix.primary_blob_endpoint}${azurerm_storage_container.artifacts.name}"
}

output "image_gallery_name" {
  value = azurerm_shared_image_gallery.foofrix.name
}

output "image_gallery_resource_group" {
  value = azurerm_resource_group.foofrix.name
}

output "windows_image_definition_id" {
  value = azurerm_shared_image.windows.id
}

output "windows_25h2_image_definition_id" {
  value = azurerm_shared_image.windows_25h2.id
}

output "windows_25h2_image_gallery_id" {
  value = azurerm_shared_image_gallery.windows_25h2.id
}

output "windows_25h2_image_gallery_name" {
  value = azurerm_shared_image_gallery.windows_25h2.name
}

output "image_build_client_id" {
  value = data.azuread_service_principal.foofrix_image_build.client_id
}

output "image_build_resource_group" {
  value = azurerm_resource_group.image_build.name
}

output "image_build_identity_id" {
  value = azurerm_user_assigned_identity.image_build.id
}

output "image_build_identity_client_id" {
  value = azurerm_user_assigned_identity.image_build.client_id
}
