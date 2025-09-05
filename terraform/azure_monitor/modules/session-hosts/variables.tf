variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vm_count" {
  type = number
}

variable "vm_size" {
  type = string
}

variable "admin_username" {
  type        = string
  description = "Bootstrap local admin username"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Bootstrap local admin password (short-lived)"
}

variable "init_script_b64" {
  type        = string
  sensitive   = true
  description = "Base64-encoded PowerShell init script"
}

variable "enable_laps" {
  type    = bool
  default = true
}

variable "laps_managed_by_intune" {
  type    = bool
  default = false
}

variable "laps_backup_directory" {
  type    = number
  default = 1
}

variable "laps_password_age_days" {
  type    = number
  default = 14
}

variable "laps_password_length" {
  type    = number
  default = 24
}

variable "laps_password_complexity" {
  type    = number
  default = 4
}

variable "laps_admin_account_name" {
  type    = string
  default = null
}