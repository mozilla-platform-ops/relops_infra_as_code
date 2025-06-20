output "virtual_network_id" {
  value = azurerm_virtual_network.this.id
}

output "azurerm_subnet_id" {
  value = azurerm_subnet.this.id
}

output "azurerm_public_ip_prefix_id" {
  value = azurerm_public_ip_prefix.this.id 
}