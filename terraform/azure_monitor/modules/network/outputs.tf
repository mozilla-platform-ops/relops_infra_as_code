output "subnet_id" { value = azurerm_subnet.this.id }
output "nsg_id"    { value = azurerm_network_security_group.this.id }
output "vnet_id"   { value = azurerm_virtual_network.this.id }