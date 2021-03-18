resource "azurerm_resource_group" "rg-central-us-gecko-t" {
  name     = "rg-central-us-gecko-t"
  location = "Central US"
  tags = merge(local.common_tags,
    map(
      "Name", "rg-central-us-gecko-t"
    )
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sacentralusgeckot" {
  name                     = "sacentralusgeckot"
  resource_group_name      = azurerm_resource_group.rg-central-us-gecko-t.name
  location                 = "Central US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    map(
      "Name", "sacentralusgeckot"
    )
  )
}
resource "azurerm_network_security_group" "nsg-central-us-gecko-t-default" {
  name                = "nsg-central-us-gecko-t-default"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.rg-central-us-gecko-t.name
  tags = merge(local.common_tags,
    map(
      "Name", "nsg-central-us-gecko-t-default"
    )
  )
}
resource "azurerm_virtual_network" "vn-central-us-gecko-t" {
  name                = "vn-central-us-gecko-t"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.rg-central-us-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-central-us-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-central-us-gecko-t-default.id
  }
  tags = merge(local.common_tags,
    map(
      "Name", "vn-central-us-gecko-t"
    )
  )
}
