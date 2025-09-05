resource "random_id" "law" { byte_length = 4 }

resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.name}-law-${random_id.law.hex}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
}

resource "azurerm_monitor_diagnostic_setting" "hp" {
  name                       = "${var.name}-diag-hp"
  target_resource_id         = var.host_pool_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log { category = "Connection" }
  enabled_log { category = "HostRegistration" }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

output "law_id"   { value = azurerm_log_analytics_workspace.this.id }
output "law_name" { value = azurerm_log_analytics_workspace.this.name }