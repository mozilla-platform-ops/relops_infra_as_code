resource "azurerm_resource_group" "this" {
  name     = "ronin-puppet-windows-assets"
  location = "westus2"
}

resource "azurerm_storage_account" "this" {
  name                     = "roninpuppetassets"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "this" {
  name                  = "binaries"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "blob"
}