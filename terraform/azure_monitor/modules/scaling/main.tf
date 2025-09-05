resource "azurerm_virtual_desktop_scaling_plan" "this" {
  name                = "${var.name}-scaling"
  location            = var.location
  resource_group_name = var.resource_group_name
  friendly_name       = "SecureScaling"
  description         = "All hosts up 100% (scaling logic retained for future use)"
  time_zone           = var.time_zone

  schedule {
    name         = "BusinessHours"
    days_of_week = ["Monday","Tuesday","Wednesday","Thursday","Friday"]

    # --- Ramp Up (also governs PEAK capacity/min) ---
    ramp_up_start_time                 = var.ramp_up_start
    ramp_up_load_balancing_algorithm   = "BreadthFirst"  # or "DepthFirst"
    ramp_up_capacity_threshold_percent = 60
    ramp_up_minimum_hosts_percent      = 100

    # PEAK: capacity/min come from ramp_up_*
    peak_start_time               = var.peak_start
    peak_load_balancing_algorithm = "BreadthFirst"

    # --- Ramp Down (also governs OFF-PEAK capacity/min) ---
    ramp_down_start_time                 = var.ramp_down_start
    ramp_down_load_balancing_algorithm   = "BreadthFirst"
    ramp_down_capacity_threshold_percent = 30
    ramp_down_minimum_hosts_percent      = 100
    ramp_down_force_logoff_users         = false
    ramp_down_stop_hosts_when            = "ZeroSessions"     # or "ZeroActiveSessions"
    ramp_down_wait_time_minutes          = 15
    ramp_down_notification_message       = "Host going to drain mode"

    # OFF-PEAK: capacity/min come from ramp_down_*
    off_peak_start_time               = var.off_peak_start
    off_peak_load_balancing_algorithm = "BreadthFirst"
  }
}

resource "azurerm_virtual_desktop_scaling_plan_host_pool_association" "assoc" {
  scaling_plan_id = azurerm_virtual_desktop_scaling_plan.this.id
  host_pool_id    = var.host_pool_id
  enabled         = true
}

output "scaling_plan_id" {
  value = azurerm_virtual_desktop_scaling_plan.this.id
}