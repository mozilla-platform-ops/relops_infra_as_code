output "dashboard_id" {
  description = "Resource ID for the Azure Portal dashboard."
  value       = azapi_resource.this.id
}
