variable "name" {
  description = "Base name for scaling plan resources"
  type        = string
}

variable "location" {
  description = "Azure region for the scaling plan"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group in which to create the scaling plan"
  type        = string
}

variable "host_pool_id" {
  description = "ID of the host pool this scaling plan should apply to"
  type        = string
}

variable "time_zone" {
  description = "Time zone for scaling schedule"
  type        = string
  default     = "Pacific Standard Time"
}

# Schedule times (24h format, local to time_zone)
variable "ramp_up_start" {
  description = "Start time for ramp up"
  type        = string
  default     = "08:00"
}

variable "peak_start" {
  description = "Start time for peak hours"
  type        = string
  default     = "09:00"
}

variable "ramp_down_start" {
  description = "Start time for ramp down"
  type        = string
  default     = "17:00"
}

variable "off_peak_start" {
  description = "Start time for off-peak period"
  type        = string
  default     = "18:00"
}
