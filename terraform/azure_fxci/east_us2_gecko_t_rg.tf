resource "azurerm_resource_group" "east_us2_gecko_t_rg" {
  name     = "east_us2_gecko_t_rg"
  location = "East US 2"
  tags = merge(local.common_tags,
    map(
      "Name", "east_us2_gecko_t_rg"
    )
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "eastus2geckotsa" {
  name                     = "eastus2geckotsa"
  resource_group_name      = azurerm_resource_group.east_us2_gecko_t_rg.name
  location                 = "East US 2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    map(
      "Name", "eastus2geckotsa"
    )
  )
}
resource "azurerm_network_security_group" "east_us2_gecko_t_default_sg" {
  name                = "east_us2_gecko_t_default_sg"
  location            = "East US 2"
  resource_group_name = azurerm_resource_group.east_us2_gecko_t_rg.name
  tags = merge(local.common_tags,
    map(
      "Name", "east_us2_gecko_t_default_sg"
    )
  )
}
resource "azurerm_virtual_network" "east_us2_gecko_t_vn" {
  name                = "east_us2_gecko_t_vn"
  location            = "East US 2"
  resource_group_name = azurerm_resource_group.east_us2_gecko_t_rg.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "east_us_gecko_t_sn"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.east_us2_gecko_t_default_sg.id
  }
  tags = merge(local.common_tags,
    map(
      "Name", "east_us2_gecko_t_vn"
    )
  )
}
