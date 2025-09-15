output "subnet_id" {
  description = "ID of the subnet created for session hosts"
  value       = azurerm_subnet.this.id
}

output "nsg_id" {
  description = "ID of the NSG associated with the subnet"
  value       = azurerm_network_security_group.this.id
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}
