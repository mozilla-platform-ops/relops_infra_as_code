resource "azurerm_resource_group" "rg-east-us-2-gecko-t" {
  name     = "rg-east-us-2-gecko-t"
  location = "East US 2"
  tags = merge(local.common_tags,
    map(
      "Name", "rg-east-us-2-gecko-t"
    )
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "saeastus2geckot" {
  name                     = "saeastus2geckot"
  resource_group_name      = azurerm_resource_group.rg-east-us-2-gecko-t.name
  location                 = "East US 2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    map(
      "Name", "saeastus2geckot"
    )
  )
}
resource "azurerm_network_security_group" "sg-east-us-2-gecko-t-default" {
  name                = "sg-east-us-2-gecko-t-default"
  location            = "East US 2"
  resource_group_name = azurerm_resource_group.rg-east-us-2-gecko-t.name
  tags = merge(local.common_tags,
    map(
      "Name", "sg-east-us-2-gecko-t-default"
    )
  )
}
resource "azurerm_virtual_network" "vn-east-us-2-gecko-t" {
  name                = "vn-east-us-2-gecko-t"
  location            = "East US 2"
  resource_group_name = azurerm_resource_group.rg-east-us-2-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "east_us_gecko_t_sn"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.sg-east-us-2-gecko-t-default.id
  }
  tags = merge(local.common_tags,
    map(
      "Name", "vn-east-us-2-gecko-t"
    )
  )
}
