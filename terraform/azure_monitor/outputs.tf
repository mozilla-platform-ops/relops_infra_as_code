output "workspace_id" { value = module.avd.workspace_id }
output "host_pool_id" { value = module.avd.host_pool_id }
output "app_group_id" { value = module.avd.app_group_id }

output "avd_url" {
  value = "https://rdweb.wvd.microsoft.com/arm/webclient/index.html"
}