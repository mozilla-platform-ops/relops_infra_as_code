/*
=================================================
DEPLOYMENT DETAILS
=================================================
*/

output "azure_tenant_id" {
  description = "Azure Tenant ID"
  value       = module.wiz_azure_outpost.azure_tenant_id
}

output "azure_subscription_id" {
  description = "Azure Subscription ID"
  value       = module.wiz_azure_outpost.azure_subscription_id
}

/*
=================================================
ORCHESTRATOR
=================================================
*/

output "wiz_da_orch_app_name" {
  description = "Orchestrator App Name"
  value       = module.wiz_azure_outpost.wiz_da_orch_app_name
}

output "wiz_da_orchestrator_client_id" {
  description = "Orchestrator Client ID"
  value       = module.wiz_azure_outpost.wiz_da_orchestrator_client_id
}

output "wiz_da_orchestrator_client_secret" {
  description = "Orchestrator Client Secret"
  sensitive   = true
  value       = module.wiz_azure_outpost.wiz_da_orchestrator_client_secret
}

/*
=================================================
CONTROL PLANE MANAGED IDENTITY
=================================================
*/

output "wiz_da_control_plane_managed_identity_id" {
  description = "Worker Managed Identity ID"
  value       = module.wiz_azure_outpost.wiz_da_control_plane_managed_identity_id
}

/*
=================================================
WORKER APP
=================================================
*/

output "wiz_da_worker_app_name" {
  description = "Worker App Name"
  value       = module.wiz_azure_outpost.wiz_da_worker_app_name
}

output "wiz_da_worker_client_id" {
  description = "Worker Client ID"
  value       = module.wiz_azure_outpost.wiz_da_worker_client_id
}

output "wiz_da_worker_client_secret" {
  description = "Worker Client Secret"
  sensitive   = true
  value       = module.wiz_azure_outpost.wiz_da_worker_client_secret
}

/*
=================================================
WORKER MANAGED IDENTITY
=================================================
*/

output "wiz_da_worker_managed_identity_id" {
  description = "Worker Managed Identity ID"
  value       = module.wiz_azure_outpost.wiz_da_worker_managed_identity_id
}

output "wiz_da_worker_managed_identity_client_id" {
  description = "Worker Managed Identity Client ID"
  value       = module.wiz_azure_outpost.wiz_da_worker_managed_identity_client_id
}

/*
=================================================
SCANNER
=================================================
*/

output "wiz_da_scanner_app_name" {
  description = "Scanner App Name"
  value       = module.wiz_azure_outpost.wiz_da_scanner_app_name
}

output "wiz_da_scanner_client_id" {
  description = "Scanner Client ID"
  value       = module.wiz_azure_outpost.wiz_da_scanner_client_id
}

output "wiz_da_scanner_client_secret" {
  description = "Scanner Client Secret"
  sensitive   = true
  value       = module.wiz_azure_outpost.wiz_da_scanner_client_secret
}

/*
=================================================
RESOURCES
=================================================
*/
output "wiz_resource_group_name" {
  description = "Resource group name"
  value       = module.wiz_azure_outpost.wiz_resource_group_name
}

output "wiz_application_keyvault_name" {
  description = "Application keyvault name"
  value       = module.wiz_azure_outpost.wiz_application_keyvault_name
}
