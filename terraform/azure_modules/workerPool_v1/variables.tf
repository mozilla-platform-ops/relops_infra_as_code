variable "location" {
  description = "The Azure region to deploy the resources in."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
}

variable "vnet_dns_servers" {
  description = "The DNS servers for the virtual network."
  type        = list(string)
}

variable "subnet_address_prefixes" {
  description = "The address prefixes for the subnet."
  type        = list(string)
}

variable "provisioner" {
  description = "The provisioner type."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resources."
  type        = map(string)
}

variable "azurerm_virtual_network_name" {
    type        = string
}

variable "azurerm_subnet_name" {
    type        = string
}

variable "azurerm_network_security_group_name" {
    type        = string
}

variable "azurerm_public_ip_prefix_name" {
    type        = string
}

variable "azurerm_storage_account_name" {
    type        = string
}

variable "nsg_security_rules" {
  description = "Security rules for the network security group."
  type        = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_ranges    = list(string)
    source_address_prefixes    = list(string)
    destination_address_prefix = string
  }))
}