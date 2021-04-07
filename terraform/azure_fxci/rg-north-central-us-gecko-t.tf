resource "azurerm_resource_group" "rg-north-central-us-gecko-t" {
  name     = "rg-north-central-us-gecko-t"
  location = "North Central US"
  tags = merge(local.common_tags,
    map(
      "Name", "rg-north-central-us-gecko-t"
    )
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sanorthcentralusgeckot" {
  name                     = "sanorthcentralusgeckot"
  resource_group_name      = azurerm_resource_group.rg-north-central-us-gecko-t.name
  location                 = "North Central US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    map(
      "Name", "sanorthcentralusgeckot"
    )
  )
}
resource "azurerm_network_security_group" "nsg-north-central-us-gecko-t" {
  name                = "nsg-north-central-us-gecko-t"
  location            = "North Central US"
  resource_group_name = azurerm_resource_group.rg-north-central-us-gecko-t.name
  tags = merge(local.common_tags,
    map(
      "Name", "nsg-north-centra-us-gecko-t"
    )
  )
}
resource "azurerm_virtual_network" "vn-north-central-us-gecko-t" {
  name                = "vn-north-central-us-gecko-t"
  location            = "North Central US"
  resource_group_name = azurerm_resource_group.rg-north-central-us-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-north-central-us-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-north-central-us-gecko-t.id
  }
  tags = merge(local.common_tags,
    map(
      "Name", "vn-north-central-us-gecko-t"
    )
  )
}
