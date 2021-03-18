resource "azurerm_resource_group" "rg-west-us-gecko-t" {
  name     = "rg-west-us-gecko-t"
  location = "West US"
  tags = merge(local.common_tags,
    map(
      "Name", "rg-west-us-gecko-t"
    )
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sawestusgeckot" {
  name                     = "sawestusgeckot"
  resource_group_name      = azurerm_resource_group.rg-west-us-gecko-t.name
  location                 = "West US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    map(
      "Name", "sawestusgeckot"
    )
  )
}
resource "azurerm_network_security_group" "nsg-west-us-gecko-t" {
  name                = "nsg-west-us-gecko-t"
  location            = "West US"
  resource_group_name = azurerm_resource_group.rg-west-us-gecko-t.name
  tags = merge(local.common_tags,
    map(
      "Name", "nsg-west-us-gecko-t"
    )
  )
}
resource "azurerm_virtual_network" "vn-west-us-gecko-t" {
  name                = "vn-west-us-gecko-t"
  location            = "West US"
  resource_group_name = azurerm_resource_group.rg-west-us-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-west-us-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-west-us-gecko-t.id
  }
  tags = merge(local.common_tags,
    map(
      "Name", "vn-west-us-gecko-t"
    )
  )
}
