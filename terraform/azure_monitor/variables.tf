# -----------------------------
# Root variables.tf
# -----------------------------

variable "prefix" {
  description = "Base name prefix for all resources"
  type        = string
}

variable "admin_username" {
  description = "Bootstrap local admin username for session hosts (short-lived; LAPS rotates)"
  type        = string
}

variable "admin_password" {
  description = "Bootstrap local admin password (short-lived; supply via TF_VAR_admin_password)"
  type        = string
  sensitive   = true
}

variable "principal_ids" {
  description = "Entra ID object IDs (users/groups) to grant Desktop Virtualization User on the Desktop App Group"
  type        = list(string)
  default     = []
}

# Multi-pool / multi-region configuration
# Keyed by a short name (e.g., 'eastus', 'westus2'); each entry creates a full AVD stack in that region.
variable "pools" {
  description = <<EOT
Map of AVD pools keyed by a short name (e.g., "eastus", "westus2").
Each value configures one pool in that region.
EOT
  type = map(object({
    location      = string
    vnet_cidr     = string
    subnet_cidr   = string
    vm_count      = number
    vm_size       = string
    image_version = optional(string) # Marketplace version for Win11 AVD (e.g., 26100.4946.250810). If unset, module default applies.
    deploy_vms    = optional(bool, true)
  }))
}
