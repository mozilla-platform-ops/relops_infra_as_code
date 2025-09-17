output "storage_account_name" {
  value       = azurerm_storage_account.sa.name
  description = "Storage account name."
}

output "container_name" {
  value       = azurerm_storage_container.c.name
  description = "Container name."
}

output "script_blob_url" {
  value       = local.blob_url
  description = "Blob URL (no SAS)."
}

output "script_blob_sas_url" {
  value       = local.sas_url
  description = "Time-limited SAS URL to the script blob."
  sensitive   = true
}
