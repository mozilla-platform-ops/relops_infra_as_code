output "vnet_id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_id" {
  description = "ID of the hosts subnet."
  value       = azurerm_subnet.subnet.id
}
