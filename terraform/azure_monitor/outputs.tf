# IDs per pool key (e.g., eastus, westus2)
output "host_pool_ids" {
  description = "AVD host pool resource IDs per pool key"
  value       = { for k, m in module.avd : k => m.host_pool_id }
}

output "app_group_ids" {
  description = "Desktop app group resource IDs per pool key"
  value       = { for k, m in module.avd : k => m.app_group_id }
}

output "workspace_ids" {
  description = "AVD workspace resource IDs per pool key"
  value       = { for k, m in module.avd : k => m.workspace_id }
}

# Convenience: static AVD web client URL
output "avd_url" {
  description = "AVD web client URL"
  value       = "https://rdweb.wvd.microsoft.com/arm/webclient/index.html"
}
