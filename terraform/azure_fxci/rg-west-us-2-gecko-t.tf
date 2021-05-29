resource "azurerm_resource_group" "rg-west-us-2-gecko-t" {
  name     = "rg-west-us-2-gecko-t"
  location = "West US 2"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-west-us-2-gecko-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sawestus2geckot" {
  name                     = "sawest2usgeckot"
  resource_group_name      = azurerm_resource_group.rg-west-us-2-gecko-t.name
  location                 = "West US 2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sawest2usgeckot"
    })
  )
}
resource "azurerm_network_security_group" "nsg-west-us2-gecko-t" {
  name                = "nsg-west-us2-gecko-t"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.rg-west-us-2-gecko-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-west-us2-gecko-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-west-us2-gecko-t" {
  name                = "vn-west-us-2-gecko-t"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.rg-west-us-2-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-west-us-2-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-west-us2-gecko-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-west-us-2-gecko-t"
    })
  )
}
