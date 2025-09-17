output "assignment_ids" {
  description = "Role assignment IDs created for the DAG scope."
  value       = [for k, v in azurerm_role_assignment.dag_access : v.id]
}
