#############################################
# Project / shared resources
#############################################

variable "project_name" {
  description = "Short project name used as a prefix for shared resources (LAW, DCR, alerts, etc.)."
  type        = string
}

variable "default_location" {
  description = "Azure region for shared/cross-pool resources (monitoring, IAM)."
  type        = string
}

variable "shared_resource_group" {
  description = "Resource group for shared/cross-pool resources (LAW, alerts, etc.)."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

#############################################
# Credentials (bootstrap)
#############################################

variable "admin_username" {
  description = "Local admin username for session hosts."
  type        = string
  default     = "avdadmin"
}

variable "admin_password" {
  description = "Local admin password (short-lived; pass via TF_VAR_admin_password)."
  type        = string
  sensitive   = true
}

#############################################
# IAM principals
#############################################

variable "principal_ids" {
  description = "Azure AD object IDs (users/groups) to grant AVD Desktop Virtualization User (per pool DAG)."
  type        = list(string)
  default     = []
}

#############################################
# Monitoring / alerts
#############################################

variable "alert_emails" {
  description = "Email recipients for monitoring alerts. If empty, an Action Group will not send emails."
  type        = list(string)
  default     = []
}

#############################################
# Pools (per-host-pool configuration)
#############################################

variable "pools" {
  description = <<EOT
Map of host pool definitions. Each key is a pool name. Supported fields:

Required per pool:
- location               : Azure region for the pool
- resource_group_name    : RG for pool resources (network, avd core, hosts)
- vnet_cidr              : vNet CIDR
- subnet_cidr            : Subnet CIDR
- vm_count               : Number of session hosts
- vm_size                : VM size for session hosts

Optional per pool:
- deploy_vms                         : bool (default: true)
- max_sessions_per_host              : int (default: 10)
- registration_token_valid_hours     : int (default: 1)
- custom_rdp_properties              : string (semicolon-separated RDP props)
- enable_laps_local                  : bool (default: true)
- init_script_uri                    : string (URI to bootstrap script) or null
- image = {
    publisher, offer, sku, version   : Marketplace image (use instead of sig_image)
  }
- sig_image = {
    gallery_name, image_name, version or version_id : SIG image (use instead of image)
  }
EOT
  type        = map(any)
}
