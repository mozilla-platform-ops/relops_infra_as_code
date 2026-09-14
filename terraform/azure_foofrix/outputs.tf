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
