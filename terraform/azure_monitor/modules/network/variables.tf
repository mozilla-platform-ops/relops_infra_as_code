variable "name" {
  description = "Short name/prefix for network resources."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for network resources."
  type        = string
}

variable "vnet_cidr" {
  description = "CIDR for the VNet."
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR for the session hosts subnet."
  type        = string
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
