variable "name" {
  description = "Base name for AVD core resources (host pool, app group, workspace)"
  type        = string
}

variable "location" {
  description = "Azure region for the AVD resources"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the AVD resources"
  type        = string
}

variable "max_sessions" {
  description = "Maximum concurrent user sessions per session host"
  type        = number
  default     = 20
}

variable "custom_rdp_properties" {
  description = "RDP property string to apply to the host pool"
  type        = string
  default     = "redirectclipboard:i:0;redirectprinters:i:0;redirectcomports:i:0;redirectsmartcards:i:0;drivestoredirect:s:;usbdevicestoredirect:s:;camerastoredirect:s:;audiocapturemode:i:0;enablerdumultimon:i:1"
}

variable "token_valid_for" {
  description = "Duration (e.g., 4h, 24h) for which the registration token is valid"
  type        = string
  default     = "4h"
}
