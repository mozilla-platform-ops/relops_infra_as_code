resource "azurerm_resource_group" "west_us_gecko_t_rg" {
  name     = "west_us_gecko_t_rg"
  location = "West US"
  tags = merge(local.common_tags,
    map(
      "Name", "west_us_gecko_t_rg"
    )
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "westusgeckotsa" {
  name                     = "westusgeckotsa"
  resource_group_name      = azurerm_resource_group.west_us_gecko_t_rg.name
  location                 = "West US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    map(
      "Name", "westusgeckotsa"
    )
  )
}
resource "azurerm_network_security_group" "west_us_gecko_t_default_sg" {
  name                = "west_us_gecko_t_default_sg"
  location            = "West US"
  resource_group_name = azurerm_resource_group.west_us_gecko_t_rg.name
  tags = merge(local.common_tags,
    map(
      "Name", "west_us_gecko_t_default_sg"
    )
  )
}
resource "azurerm_virtual_network" "west_us_gecko_t_vn" {
  name                = "west_us_gecko_t_vn"
  location            = "West US"
  resource_group_name = azurerm_resource_group.west_us_gecko_t_rg.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "west_us_gecko_t_sn"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.west_us_gecko_t_default_sg.id
  }
  tags = merge(local.common_tags,
    map(
      "Name", "west_us_gecko_t_vn"
    )
  )
}
