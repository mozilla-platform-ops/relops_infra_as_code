#############################################
# AVD Core
#############################################

output "hostpool_ids" {
  description = "IDs of the AVD host pools created (by pool key)."
  value       = { for k, v in module.avd_core : k => v.hostpool_id }
}

output "workspace_ids" {
  description = "IDs of the AVD Workspaces created (by pool key)."
  value       = { for k, v in module.avd_core : k => v.workspace_id }
}

output "app_group_ids" {
  description = "IDs of the Desktop Application Groups (by pool key)."
  value       = { for k, v in module.avd_core : k => v.app_group_id }
}

output "registration_tokens" {
  description = "Registration tokens per pool (sensitive; short-lived)."
  value       = { for k, v in module.avd_core : k => v.registration_token }
  sensitive   = true
}

#############################################
# Session Hosts
#############################################

output "session_host_vm_ids" {
  description = "Session host VM IDs per pool."
  value       = { for k, v in module.session_hosts : k => try(v.vm_ids, []) }
}

output "session_host_vm_names" {
  description = "Session host VM names per pool."
  value       = { for k, v in module.session_hosts : k => try(v.vm_names, []) }
}

#############################################
# Monitoring (shared)
#############################################

output "monitoring_workspace_id" {
  description = "Resource ID of the central Log Analytics Workspace."
  value       = module.monitoring.workspace_id
}

output "monitoring_dcr_id" {
  description = "Resource ID of the Data Collection Rule."
  value       = module.monitoring.dcr_id
}

output "monitoring_action_group_id" {
  description = "Action Group ID used by alerts."
  value       = module.monitoring.action_group_id
}

#############################################
# IAM (per pool)
#############################################

output "iam_assignment_ids" {
  description = "Role assignment IDs per pool."
  value       = { for k, v in module.iam_assignments : k => try(v.assignment_ids, []) }
}
