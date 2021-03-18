resource "azurerm_resource_group" "rg-south-central-us-gecko-t" {
  name     = "rg-south-central-us-gecko-t"
  location = "South Central US"
  tags = merge(local.common_tags,
    map(
      "Name", "rg-south-central-us-gecko-t"
    )
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sasouthcentralusgeckot" {
  name                     = "sasouthcentralusgeckot"
  resource_group_name      = azurerm_resource_group.rg-south-central-us-gecko-t.name
  location                 = "South Central US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    map(
      "Name", "sasouthcentralusgeckot"
    )
  )
}
resource "azurerm_network_security_group" "nsg-south-central-us-gecko-t-default" {
  name                = "nsg-south-central-us-gecko-t-default"
  location            = "South Central US"
  resource_group_name = azurerm_resource_group.rg-south-central-us-gecko-t.name
  tags = merge(local.common_tags,
    map(
      "Name", "nsg-south-central-us-gecko-t-default"
    )
  )
}
resource "azurerm_virtual_network" "vn-south-central-us-gecko-t" {
  name                = "vn-south-central-us-gecko-t"
  location            = "South Central US"
  resource_group_name = azurerm_resource_group.rg-south-central-us-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-south-central-us-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-south-central-us-gecko-t-default.id
  }
  tags = merge(local.common_tags,
    map(
      "Name", "vn-south-central-us-gecko-t"
    )
  )
}
