output "hostpool_id" {
  value       = azurerm_virtual_desktop_host_pool.this.id
  description = "Resource ID of the host pool."
}

output "workspace_id" {
  value       = azurerm_virtual_desktop_workspace.this.id
  description = "Resource ID of the AVD Workspace."
}

output "app_group_id" {
  value       = azurerm_virtual_desktop_application_group.desktop.id
  description = "Resource ID of the Desktop Application Group (DAG)."
}

output "registration_token" {
  value       = azurerm_virtual_desktop_host_pool_registration_info.ttl.token
  description = "Current registration token (sensitive; short TTL)."
  sensitive   = true
}
