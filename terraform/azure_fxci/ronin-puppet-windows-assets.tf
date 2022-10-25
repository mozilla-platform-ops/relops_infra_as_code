resource "azurerm_resource_group" "ronin-puppet-windows-assets" {
  name     = "ronin-puppet-windows-assets"
  location = "westus2"
}

resource "azurerm_storage_account" "ronin-puppet-windows-assets" {
  name                     = "roninpuppetassets"
  resource_group_name      = azurerm_resource_group.ronin-puppet-windows-assets.name
  location                 = azurerm_resource_group.ronin-puppet-windows-assets.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "ronin-puppet-windows-assets" {
  name                  = "binaries"
  storage_account_name  = azurerm_storage_account.ronin-puppet-windows-assets.name
  container_access_type = "blob"
}