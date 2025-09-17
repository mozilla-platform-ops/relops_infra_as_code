#############################################
# Log Analytics Workspace
#############################################

output "workspace_id" {
  description = "Resource ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "workspace_name" {
  description = "Name of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.name
}

output "workspace_location" {
  description = "Location of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.location
}

output "workspace_primary_shared_key" {
  description = "Primary shared key for the LAW."
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

#############################################
# Data Collection Rule
#############################################

output "dcr_id" {
  description = "ID of the Azure Monitor Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.this.id
}

output "dcr_name" {
  description = "Name of the Azure Monitor Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.this.name
}

#############################################
# Action Group
#############################################

output "action_group_id" {
  description = "ID of the Action Group used by alerts (created or supplied)."
  value       = local.action_group_id
}
