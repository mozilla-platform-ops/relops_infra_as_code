variable "name" {
  description = "Short name used to name VMs/NICs."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for session hosts."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for NICs."
  type        = string
}

variable "hostpool_id" {
  description = "Host pool ID used by init script."
  type        = string
}

variable "registration_token" {
  description = "Registration token used by init script."
  type        = string
  sensitive   = true
}

variable "vm_count" {
  description = "Number of session hosts to create."
  type        = number
}

variable "vm_size" {
  description = "VM size for session hosts."
  type        = string
}

variable "computer_name_prefix" {
  description = "Prefix for computer names; module truncates so that <prefix>-### is <= 15 chars."
  type        = string
}

variable "image" {
  description = "Marketplace image (publisher/offer/sku/version)."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = null
}

variable "sig_image" {
  description = "SIG image reference."
  type = object({
    image_id = string
  })
  default = null
}

variable "admin_username" {
  description = "Local admin username."
  type        = string
}

variable "admin_password" {
  description = "Local admin password."
  type        = string
  sensitive   = true
}

variable "enable_aad_login" {
  description = "Install AADLoginForWindows extension."
  type        = bool
  default     = true
}

variable "init_script_uri" {
  description = "HTTP(S) URI for avd-session-init.ps1 (SAS URL)."
  type        = string
  default     = null
  sensitive   = true
}

variable "enable_laps_local" {
  description = "Whether to enable local LAPS config in the init script."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

# DCR association (optional, but recommended)
variable "dcr_id" {
  description = "Data Collection Rule ID to associate with each VM (optional)."
  type        = string
  default     = null
}

variable "enable_dcr_association" {
  description = "Create DCR associations to each VM when dcr_id is provided."
  type        = bool
  default     = true
}
