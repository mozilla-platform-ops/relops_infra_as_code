resource "azurerm_resource_group" "central_us_gecko_t_rg" {
  name     = "central_us_gecko_t_rg"
  location = "Central US"
  tags = merge(local.common_tags,
    map(
      "Name", "central_us_gecko_t_rg"
    )
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "centralusgeckotsa" {
  name                     = "centralusgeckotsa"
  resource_group_name      = azurerm_resource_group.central_us_gecko_t_rg.name
  location                 = "Central US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    map(
      "Name", "centralusgeckotsa"
    )
  )
}
resource "azurerm_network_security_group" "central_us_gecko_t_default_sg" {
  name                = "central_us_gecko_t_default_sg"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.central_us_gecko_t_rg.name
  tags = merge(local.common_tags,
    map(
      "Name", "central_us_gecko_t_default_sg"
    )
  )
}
resource "azurerm_virtual_network" "central_us_gecko_t_vn" {
  name                = "central_us_gecko_t_vn"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.central_us_gecko_t_rg.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "central_us_gecko_t_sn"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.central_us_gecko_t_default_sg.id
  }
  tags = merge(local.common_tags,
    map(
      "Name", "central_us_gecko_t_vn"
    )
  )
}
