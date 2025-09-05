variable "prefix" {
  type    = string
  default = "avd-secure"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "resource_group" {
  type    = string
  default = "rg-avd-secure"
}

variable "vnet_cidr" {
  type    = string
  default = "10.90.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.90.1.0/24"
}

variable "vm_count" {
  type    = number
  default = 2
}

variable "vm_size" {
  type    = string
  default = "Standard_D8s_v5"
}

# -------------------------------------------------------------------
# Bootstrap Admin Credentials (short-lived)
# Inject at runtime via TF_VAR_... env vars. Do NOT commit secrets.
# -------------------------------------------------------------------
variable "deploy_vms" {
  type    = bool
  default = false
}

variable "admin_username" {
  type        = string
  description = "Bootstrap local admin username for session hosts (short-lived)"
  validation {
    condition     = length(var.admin_username) > 0
    error_message = "admin_username must not be empty."
  }
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Bootstrap local admin password (short-lived; rotated on first boot)"
  validation {
    condition     = length(var.admin_password) > 0
    error_message = "admin_password must not be empty."
  }
}

variable "principal_ids" {
  type        = list(string)
  default     = []
  description = "Entra ID object IDs (users/groups) to grant Desktop Virtualization User on the Desktop App Group."
}