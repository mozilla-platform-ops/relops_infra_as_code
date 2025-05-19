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

variable "nat_gateway_name" {
  description = "The name of the NAT gateway."
  type        = string  
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

variable "azurerm_public_ip_name" {
    type        = string
}

variable "azurerm_storage_account_name" {
    type        = string
}
