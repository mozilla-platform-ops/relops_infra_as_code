resource "azurerm_resource_group" "north_central_us_gecko_t_rg" {
  name     = "north_central_us_gecko_t_rg"
  location = "North Central US"
  tags = merge(local.common_tags,
    map(
      "Name", "north_central_us_gecko_t_rg"
    )
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "north_centralusgeckotsa" {
  name                     = "north_centralusgeckotsa"
  resource_group_name      = azurerm_resource_group.north_central_us_gecko_t_rg.name
  location                 = "North Central US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    map(
      "Name", "north_centralusgeckotsa"
    )
  )
}
resource "azurerm_network_security_group" "north_central_us_gecko_t_default_sg" {
  name                = "north_central_us_gecko_t_default_sg"
  location            = "North Central US"
  resource_group_name = azurerm_resource_group.north_central_us_gecko_t_rg.name
  tags = merge(local.common_tags,
    map(
      "Name", "north_central_us_gecko_t_default_sg"
    )
  )
}
resource "azurerm_virtual_network" "north_central_us_gecko_t_vn" {
  name                = "north_central_us_gecko_t_vn"
  location            = "North Central US"
  resource_group_name = azurerm_resource_group.north_central_us_gecko_t_rg.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "north_central_us_gecko_t_sn"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.north_central_us_gecko_t_default_sg.id
  }
  tags = merge(local.common_tags,
    map(
      "Name", "north_central_us_gecko_t_vn"
    )
  )
}
