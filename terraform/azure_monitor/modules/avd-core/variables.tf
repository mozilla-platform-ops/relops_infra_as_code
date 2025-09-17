variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "hostpool_friendly_name" {
  type    = string
  default = null
}

variable "hostpool_type" {
  type    = string
  default = "Pooled"
}

variable "load_balancer_type" {
  type    = string
  default = "BreadthFirst"
}

variable "max_sessions_per_host" {
  type    = number
  default = 10
}

variable "custom_rdp_properties" {
  type    = string
  default = null
}

variable "registration_token_valid_hours" {
  type    = number
  default = 1
}

variable "workspace_resource_id" {
  description = "LAW ID for diagnostics (optional)."
  type        = string
  default     = null
}

variable "enable_diagnostics" {
  description = "Create diagnostic settings (count is plan-known via this flag)."
  type        = bool
  default     = true
}
