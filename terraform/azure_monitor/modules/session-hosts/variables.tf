variable "name" {
  description = "Base name for the session host resources"
  type        = string
}

variable "location" {
  description = "Azure region for the session hosts"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group in which to create the session hosts"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the session hosts will be deployed"
  type        = string
}

variable "vm_count" {
  description = "Number of session host VMs to create in this pool"
  type        = number
}

variable "vm_size" {
  description = "Size (SKU) of the session host VMs"
  type        = string
}

variable "admin_username" {
  description = "Bootstrap local admin username (short-lived; rotated by LAPS)"
  type        = string
}

variable "admin_password" {
  description = "Bootstrap local admin password (short-lived; rotated by LAPS)"
  type        = string
  sensitive   = true
}

variable "init_script_b64" {
  description = "Base64-encoded PowerShell init script (runs on first boot / logon)"
  type        = string
  sensitive   = true
}

# Optional: pin Marketplace image version (useful for multi-region)
variable "image_version" {
  description = "Optional Marketplace image version for Win11 AVD (e.g., 26100.4946.250810)"
  type        = string
  default     = null
}

# -------------------------
# Windows LAPS configuration
# -------------------------
variable "enable_laps" {
  description = "Enable Windows LAPS (Local Administrator Password Solution)"
  type        = bool
  default     = true
}

variable "laps_managed_by_intune" {
  description = "If true, assume Intune delivers LAPS policy; if false, apply local config"
  type        = bool
  default     = false
}

variable "laps_backup_directory" {
  description = "Where LAPS should back up passwords (1=Entra ID, 2=AD, 0=Disabled)"
  type        = number
  default     = 1
}

variable "laps_password_age_days" {
  description = "Number of days before rotating the local admin password"
  type        = number
  default     = 14
}

variable "laps_password_length" {
  description = "Length of generated local admin password"
  type        = number
  default     = 24
}

variable "laps_password_complexity" {
  description = "Password complexity mode (4=upper/lower/numbers/specials)"
  type        = number
  default     = 4
}

variable "laps_admin_account_name" {
  description = "Optional: custom local admin account name (null uses built-in Administrator RID)"
  type        = string
  default     = null
}
