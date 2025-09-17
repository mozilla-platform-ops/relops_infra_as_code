locals {
  plan_name = "${var.name}-sp"
}

resource "azurerm_virtual_desktop_scaling_plan" "this" {
  name                = local.plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  time_zone           = var.timezone
  tags                = var.tags

  dynamic "schedule" {
    for_each = var.provide_schedules ? var.schedules : []

    content {
      name                                 = schedule.value.name
      days_of_week                         = schedule.value.days_of_week
      ramp_up_start_time                   = schedule.value.ramp_up_start_time
      ramp_up_load_balancing_algorithm     = schedule.value.ramp_up_load_balancing_algorithm
      ramp_up_minimum_hosts_percent        = schedule.value.ramp_up_minimum_hosts_pct
      ramp_up_capacity_threshold_percent   = schedule.value.ramp_up_capacity_threshold_percent
      peak_start_time                      = schedule.value.peak_start_time
      peak_load_balancing_algorithm        = schedule.value.peak_load_balancing_algorithm
      ramp_down_start_time                 = schedule.value.ramp_down_start_time
      ramp_down_load_balancing_algorithm   = schedule.value.ramp_down_load_balancing_algorithm
      ramp_down_minimum_hosts_percent      = schedule.value.ramp_down_minimum_hosts_percent
      ramp_down_capacity_threshold_percent = schedule.value.ramp_down_capacity_threshold_percent
      ramp_down_force_logoff_users         = schedule.value.ramp_down_force_logoff_users
      ramp_down_wait_time_minutes          = schedule.value.ramp_down_wait_time_minutes
      ramp_down_stop_hosts_when            = schedule.value.ramp_down_stop_hosts_when
      ramp_down_notification_message       = schedule.value.ramp_down_notification_message
      off_peak_start_time                  = schedule.value.off_peak_start_time
      off_peak_load_balancing_algorithm    = schedule.value.off_peak_load_balancing_algorithm
    }
  }

  dynamic "schedule" {
    for_each = var.provide_schedules ? [] : [1]

    content {
      name         = "always-on"
      days_of_week = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

      ramp_up_start_time                 = "00:00"
      ramp_up_load_balancing_algorithm   = "BreadthFirst"
      ramp_up_minimum_hosts_percent      = 100
      ramp_up_capacity_threshold_percent = 90

      peak_start_time               = "00:30"
      peak_load_balancing_algorithm = "BreadthFirst"

      ramp_down_start_time                 = "22:00"
      ramp_down_load_balancing_algorithm   = "BreadthFirst"
      ramp_down_minimum_hosts_percent      = 100
      ramp_down_capacity_threshold_percent = 90
      ramp_down_force_logoff_users         = false
      ramp_down_wait_time_minutes          = 60
      ramp_down_stop_hosts_when            = "ZeroSessions"
      ramp_down_notification_message       = "Scaling down session hosts"

      off_peak_start_time               = "23:59"
      off_peak_load_balancing_algorithm = "BreadthFirst"
    }
  }
}

resource "azurerm_virtual_desktop_scaling_plan_host_pool_association" "assoc" {
  scaling_plan_id = azurerm_virtual_desktop_scaling_plan.this.id
  host_pool_id    = var.host_pool_id
  enabled         = var.association_enabled
}
