locals {
  hp_name   = "${var.name}-hp"
  ws_name   = "${var.name}-ws"
  dag_name  = "${var.name}-dag"
  diag_name = "${var.name}-hp-diag"

  friendly  = coalesce(var.hostpool_friendly_name, local.hp_name)
  rdp_props = trimspace(coalesce(var.custom_rdp_properties, ""))
}

resource "azurerm_virtual_desktop_host_pool" "this" {
  name                = local.hp_name
  location            = var.location
  resource_group_name = var.resource_group_name

  type               = var.hostpool_type
  load_balancer_type = var.load_balancer_type

  maximum_sessions_allowed = var.hostpool_type == "Pooled" ? var.max_sessions_per_host : null

  friendly_name         = local.friendly
  custom_rdp_properties = length(local.rdp_props) > 0 ? local.rdp_props : null

  tags = var.tags
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "ttl" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.this.id
  expiration_date = timeadd(timestamp(), "${max(2, var.registration_token_valid_hours)}h")
}

resource "azurerm_virtual_desktop_workspace" "this" {
  name                = local.ws_name
  location            = var.location
  resource_group_name = var.resource_group_name
  friendly_name       = local.ws_name
  tags                = var.tags
}

resource "azurerm_virtual_desktop_application_group" "desktop" {
  name                = local.dag_name
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.this.id
  friendly_name       = local.dag_name
  tags                = var.tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "link" {
  workspace_id         = azurerm_virtual_desktop_workspace.this.id
  application_group_id = azurerm_virtual_desktop_application_group.desktop.id
}

resource "azurerm_monitor_diagnostic_setting" "host_pool" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = local.diag_name
  target_resource_id         = azurerm_virtual_desktop_host_pool.this.id
  log_analytics_workspace_id = var.workspace_resource_id

  enabled_log { category = "Error" }
  enabled_log { category = "Checkpoint" }
  enabled_log { category = "Connection" }
  enabled_log { category = "HostRegistration" }
  enabled_log { category = "Management" }
}
