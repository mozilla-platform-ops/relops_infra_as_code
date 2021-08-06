resource "azurerm_resource_group" "rg-west-europe-gecko-t" {
  name     = "rg-west-europe-gecko-t"
  location = "West Europe"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-west-europe-gecko-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sawesteuropegeckot" {
  name                     = "sawesteuropegeckot"
  resource_group_name      = azurerm_resource_group.rg-west-europe-gecko-t.name
  location                 = "West Europe"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sawesteuropegeckot"
    })
  )
}
resource "azurerm_network_security_group" "nsg-west-europe-gecko-t" {
  name                = "nsg-west-europe-gecko-t"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.rg-west-europe-gecko-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-west-europe-gecko-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-west-europe-gecko-t" {
  name                = "vn-west-europe-gecko-t"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.rg-west-europe-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-west-europe-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-west-europe-gecko-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-west-europe-gecko-t"
    })
  )
}
