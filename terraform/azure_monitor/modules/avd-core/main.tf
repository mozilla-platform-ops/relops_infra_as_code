resource "azurerm_virtual_desktop_host_pool" "this" {
  name                     = "${var.name}-hp"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  type                     = "Pooled"
  load_balancer_type       = "BreadthFirst"
  maximum_sessions_allowed = var.max_sessions
  friendly_name            = "${var.name}-pooled"
  start_vm_on_connect      = true
  custom_rdp_properties    = var.custom_rdp_properties

  scheduled_agent_updates {
    enabled  = true
    timezone = "UTC"

    schedule {
      day_of_week = "Saturday"
      hour_of_day = 3
    }
  }
}

resource "azurerm_virtual_desktop_application_group" "desktop" {
  name                = "${var.name}-dag-desktop"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.this.id
  friendly_name       = "Secure Desktop"
}

resource "azurerm_virtual_desktop_workspace" "this" {
  name                = "${var.name}-ws"
  location            = var.location
  resource_group_name = var.resource_group_name
  friendly_name       = "Secure Workspace"
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "assoc" {
  workspace_id         = azurerm_virtual_desktop_workspace.this.id
  application_group_id = azurerm_virtual_desktop_application_group.desktop.id
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "reg" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.this.id
  expiration_date = timeadd(timestamp(), var.token_valid_for)
}

output "host_pool_id" {
  description = "ID of the AVD host pool"
  value       = azurerm_virtual_desktop_host_pool.this.id
}

output "app_group_id" {
  description = "ID of the AVD desktop application group"
  value       = azurerm_virtual_desktop_application_group.desktop.id
}

output "workspace_id" {
  description = "ID of the AVD workspace"
  value       = azurerm_virtual_desktop_workspace.this.id
}

output "registration_token" {
  description = "Registration token for session host registration"
  value       = azurerm_virtual_desktop_host_pool_registration_info.reg.token
  sensitive   = true
}
