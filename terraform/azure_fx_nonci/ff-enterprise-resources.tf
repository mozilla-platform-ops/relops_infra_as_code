resource "azurerm_resource_group" "rg-north-central-us-ff-enterprise" {
  name     = "rg-north-central-us-ff-enterprise"
  location = "North Central US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-north-central-us-ff-enterprise"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sanorthcentralusffenterp" {
  name                     = "sanorthcentralusffenterp"
  resource_group_name      = azurerm_resource_group.rg-north-central-us-ff-enterprise.name
  location                 = "North Central US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sanorthcentralusffenterp"
    })
  )
}
resource "azurerm_network_security_group" "nsg-north-central-us-ff-enterprise" {
  name                = "nsg-north-central-us-ff-enterprise"
  location            = "North Central US"
  resource_group_name = azurerm_resource_group.rg-north-central-us-ff-enterprise.name
  security_rule {
    name                       = "allow-rdp"
    description                = "allow-rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-north-central-us-ff-enterprise"
    })
  )
}
resource "azurerm_virtual_network" "vn-north-central-us-ff-enterprise1" {
  name                = "vn-north-central-us-ff-enterprise1"
  location            = "North Central US"
  resource_group_name = azurerm_resource_group.rg-north-central-us-ff-enterprise.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-north-central-us-ff-enterprise"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-north-central-us-ff-enterprise.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-north-central-us-ff-enterprise"
    })
  )
}
