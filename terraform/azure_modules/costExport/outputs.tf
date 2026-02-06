output "id" {
  description = "The ID of the cost export"
  value       = azapi_resource.cost_export.id
}

output "name" {
  description = "The name of the cost export"
  value       = azapi_resource.cost_export.name
}

output "identity" {
  description = "The identity of the cost export (including principal_id for RBAC assignments)"
  value       = azapi_resource.cost_export.identity
}

output "output" {
  description = "The full output of the cost export resource"
  value       = azapi_resource.cost_export.output
}
