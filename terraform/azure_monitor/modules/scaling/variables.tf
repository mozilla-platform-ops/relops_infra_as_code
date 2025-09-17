variable "name" {
  description = "Short name used to prefix the scaling plan."
  type        = string
}

variable "location" {
  description = "Azure region for the scaling plan."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the scaling plan."
  type        = string
}

variable "host_pool_id" {
  description = "Resource ID of the host pool to associate with this scaling plan."
  type        = string
}

variable "timezone" {
  description = "Time zone for schedules (e.g., 'Pacific Standard Time')."
  type        = string
  default     = "UTC"
}

variable "tags" {
  description = "Tags to apply to the scaling plan."
  type        = map(string)
  default     = {}
}

variable "provide_schedules" {
  description = "If true, use the provided 'schedules' list; otherwise create a 24x7 always-on schedule."
  type        = bool
  default     = false
}

variable "schedules" {
  description = <<EOT
List of scaling schedule objects. Each item:
{
  name                                 = string
  days_of_week                         = list(string)
  ramp_up_start_time                   = string
  ramp_up_load_balancing_algorithm     = string
  ramp_up_minimum_hosts_pct            = number
  ramp_up_capacity_threshold_percent   = number
  peak_start_time                      = string
  peak_load_balancing_algorithm        = string
  ramp_down_start_time                 = string
  ramp_down_load_balancing_algorithm   = string
  ramp_down_minimum_hosts_percent      = number
  ramp_down_capacity_threshold_percent = number
  ramp_down_force_logoff_users         = bool
  ramp_down_wait_time_minutes          = number
  ramp_down_stop_hosts_when            = string   # "ZeroSessions" | "ZeroActiveSessions"
  ramp_down_notification_message       = string
  off_peak_start_time                  = string
  off_peak_load_balancing_algorithm    = string
}
EOT
  type = list(object({
    name                                 = string
    days_of_week                         = list(string)
    ramp_up_start_time                   = string
    ramp_up_load_balancing_algorithm     = string
    ramp_up_minimum_hosts_pct            = number
    ramp_up_capacity_threshold_percent   = number
    peak_start_time                      = string
    peak_load_balancing_algorithm        = string
    ramp_down_start_time                 = string
    ramp_down_load_balancing_algorithm   = string
    ramp_down_minimum_hosts_percent      = number
    ramp_down_capacity_threshold_percent = number
    ramp_down_force_logoff_users         = bool
    ramp_down_wait_time_minutes          = number
    ramp_down_stop_hosts_when            = string
    ramp_down_notification_message       = string
    off_peak_start_time                  = string
    off_peak_load_balancing_algorithm    = string
  }))
  default = []
}

variable "association_enabled" {
  description = "Whether the host pool association to the scaling plan is enabled."
  type        = bool
  default     = true
}
