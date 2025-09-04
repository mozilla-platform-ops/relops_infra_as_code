/*
=================================================
DEPLOYMENT DETAILS
=================================================
*/

output "azure_tenant_id" {
  description = "Azure Tenant ID"
  value       = var.azure_tenant_id
}

output "azure_subscription_id" {
  description = "Azure Subscription ID"
  value       = var.azure_subscription_id
}

/*
=================================================
ORCHESTRATOR
=================================================
*/

output "wiz_da_orch_app_name" {
  description = "Orchestrator App Name"
  value       = local.use_orchestrator_wiz_managed_app ? null : azuread_application.wiz_da_orchestrator[0].display_name
}

output "wiz_da_orchestrator_client_id" {
  description = "Orchestrator Client ID"
  value       = local.use_orchestrator_wiz_managed_app ? null : azuread_application.wiz_da_orchestrator[0].client_id
}

output "wiz_da_orchestrator_client_secret" {
  description = "Orchestrator Client Secret"
  sensitive   = true
  value       = local.use_orchestrator_wiz_managed_app ? null : azuread_application_password.wiz_da_orchestrator_pass[0].value
}

/*
=================================================
CONTROL PLANE MANAGED IDENTITY
=================================================
*/

output "wiz_da_control_plane_managed_identity_id" {
  description = "Worker Managed Identity ID"
  value       = var.use_worker_managed_identity ? azurerm_user_assigned_identity.wiz_da_control_plane_identity[0].id : ""
}

/*
=================================================
WORKER APP
=================================================
*/

output "wiz_da_worker_app_name" {
  description = "Worker App Name"
  value       = var.use_worker_managed_identity ? "" : azuread_application.wiz_da_worker[0].display_name
}

output "wiz_da_worker_client_id" {
  description = "Worker Client ID"
  value       = var.use_worker_managed_identity ? "" : azuread_application.wiz_da_worker[0].client_id
}

output "wiz_da_worker_client_secret" {
  description = "Worker Client Secret"
  sensitive   = true
  value       = var.use_worker_managed_identity ? "" : azuread_application_password.wiz_da_worker_pass[0].value
}

/*
=================================================
WORKER MANAGED IDENTITY
=================================================
*/

output "wiz_da_worker_managed_identity_id" {
  description = "Worker Managed Identity ID"
  value       = var.use_worker_managed_identity ? azurerm_user_assigned_identity.wiz_da_worker_identity[0].id : ""
}

output "wiz_da_worker_managed_identity_client_id" {
  description = "Worker Managed Identity Client ID"
  value       = var.use_worker_managed_identity ? azurerm_user_assigned_identity.wiz_da_worker_identity[0].client_id : ""
}

/*
=================================================
SCANNER
=================================================
*/

output "wiz_da_scanner_app_name" {
  description = "Scanner App Name"
  value       = azuread_application.wiz_da_scanner.display_name
}

output "wiz_da_scanner_client_id" {
  description = "Scanner Client ID"
  value       = azuread_application.wiz_da_scanner.client_id
}

output "wiz_da_scanner_client_secret" {
  description = "Scanner Client Secret"
  sensitive   = true
  value       = azuread_application_password.wiz_da_scanner_pass.value
}

/*
=================================================
RESOURCES
=================================================
*/
output "wiz_resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.wiz_orchestrator_rg.name
}

output "wiz_application_keyvault_name" {
  description = "Application keyvault name"
  value       = azurerm_key_vault.wiz_outpost_keyvault.name
}
