variable "name" {
  description = "Base name for network resources"
  type        = string
}

variable "location" {
  description = "Azure region for the network"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the network resources will be deployed"
  type        = string
}

variable "vnet_cidr" {
  description = "CIDR block for the virtual network"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet used by session hosts"
  type        = string
}
