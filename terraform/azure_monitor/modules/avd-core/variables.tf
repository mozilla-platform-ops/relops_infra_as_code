variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "max_sessions" {
  type    = number
  default = 20
}

variable "custom_rdp_properties" {
  type    = string
  default = "redirectclipboard:i:0;redirectprinters:i:0;redirectcomports:i:0;redirectsmartcards:i:0;drivestoredirect:s:;usbdevicestoredirect:s:;camerastoredirect:s:;audiocapturemode:i:0;enablerdumultimon:i:1"
}

variable "token_valid_for" {
  type    = string
  default = "4h"
}
