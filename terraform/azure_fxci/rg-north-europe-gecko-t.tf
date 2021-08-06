resource "azurerm_resource_group" "rg-north-europe-gecko-t" {
  name     = "rg-north-europe-gecko-t"
  location = "North Europe"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-north-europe-gecko-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sanortheuropegeckot" {
  name                     = "sanorthcentralusgeckot"
  resource_group_name      = azurerm_resource_group.rg-north-europe-gecko-t.name
  location                 = "North Europe"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sanortheuropegeckot"
    })
  )
}
resource "azurerm_network_security_group" "nsg-north-europe-gecko-t" {
  name                = "nsg-north-europe-gecko-t"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.rg-north-europe-gecko-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-north-europe-gecko-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-north-europe-gecko-t" {
  name                = "vn-north-europe-gecko-t"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.rg-north-europe-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-north-europe-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-north-europe-gecko-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-north-europe-gecko-t"
    })
  )
}
