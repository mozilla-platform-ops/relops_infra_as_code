resource "azurerm_resource_group" "south_central_us_gecko_t_rg" {
  name     = "south_central_us_gecko_t_rg"
  location = "South Central US"
  tags = merge(local.common_tags,
    map(
      "Name", "south_central_us_gecko_t_rg"
    )
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "southcentralusgeckotsa" {
  name                     = "southcentralusgeckotsa"
  resource_group_name      = azurerm_resource_group.south_central_us_gecko_t_rg.name
  location                 = "South Central US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    map(
      "Name", "southcentralusgeckotsa"
    )
  )
}
resource "azurerm_network_security_group" "south_central_us_gecko_t_default_sg" {
  name                = "south_central_us_gecko_t_default_sg"
  location            = "South Central US"
  resource_group_name = azurerm_resource_group.south_central_us_gecko_t_rg.name
  tags = merge(local.common_tags,
    map(
      "Name", "south_central_us_gecko_t_default_sg"
    )
  )
}
resource "azurerm_virtual_network" "south_central_us_gecko_t_vn" {
  name                = "south_central_us_gecko_t_vn"
  location            = "South Central US"
  resource_group_name = azurerm_resource_group.south_central_us_gecko_t_rg.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "south_central_us_gecko_t_sn"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.south_central_us_gecko_t_default_sg.id
  }
  tags = merge(local.common_tags,
    map(
      "Name", "south_central_us_gecko_t_vn"
    )
  )
}
