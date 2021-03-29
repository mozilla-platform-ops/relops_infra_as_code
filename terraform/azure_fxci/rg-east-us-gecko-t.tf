resource "azurerm_resource_group" "rg-east-us-gecko-t" {
  name     = "rg-east-us-gecko-t"
  location = "East US"
  tags = merge(local.common_tags,
    map(
      "Name", "rg-east-us-gecko-t"
    )
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "saeastusgeckot" {
  name                     = "saeastusgeckot"
  resource_group_name      = azurerm_resource_group.rg-east-us-gecko-t.name
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    map(
      "Name", "saeastusgeckot"
    )
  )
}
resource "azurerm_network_security_group" "nsg-east-us-gecko-t" {
  name                = "nsg-east-us-gecko-t"
  location            = "East US"
  resource_group_name = azurerm_resource_group.rg-east-us-gecko-t.name
  tags = merge(local.common_tags,
    map(
      "Name", "nsg-east-us-gecko-t"
    )
  )
}
resource "azurerm_virtual_network" "vn-east-us-gecko-t" {
  name                = "vn-east-us-gecko-t"
  location            = "East US"
  resource_group_name = azurerm_resource_group.rg-east-us-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-east-us-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-east-us-gecko-t.id
  }
  tags = merge(local.common_tags,
    map(
      "Name", "vn-east-us-gecko-t"
    )
  )
}
