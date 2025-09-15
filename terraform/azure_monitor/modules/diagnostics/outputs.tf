output "law_id" {
  description = "ID of the Log Analytics workspace created for diagnostics"
  value       = azurerm_log_analytics_workspace.this.id
}

output "law_name" {
  description = "Name of the Log Analytics workspace created for diagnostics"
  value       = azurerm_log_analytics_workspace.this.name
}
