variable "name" {
  description = "Base name for diagnostics resources"
  type        = string
}

variable "location" {
  description = "Azure region for the Log Analytics workspace"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for diagnostics resources"
  type        = string
}

variable "host_pool_id" {
  description = "ID of the host pool to attach diagnostics to"
  type        = string
}

variable "retention_days" {
  description = "Retention period (in days) for Log Analytics workspace data"
  type        = number
  default     = 30
}
