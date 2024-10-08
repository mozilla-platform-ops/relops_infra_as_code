resource "azurerm_resource_group" "mozilla1" {
  for_each = var.mozilla1
  name     = "rg-${each.value.rgname}"
  location = each.value.rglocation
  tags = merge(local.common_tags,
    tomap({
      "Name" = "${each.value.rgname}"
    })
  )
}

resource "azurerm_storage_account" "mozilla1" {
  for_each                 = var.mozilla1
  name                     = replace("sa${each.value.rgname}", "/\\W|_|\\s/", "")
  resource_group_name      = azurerm_resource_group.mozilla1[each.key].name
  location                 = each.value.rglocation
  account_replication_type = "GRS"
  account_tier             = "Standard"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "${each.value.rgname}"
    })
  )
}

resource "azurerm_network_security_group" "mozilla1" {
  for_each            = var.mozilla1
  name                = "nsg-${each.value.rgname}"
  resource_group_name = azurerm_resource_group.mozilla1[each.key].name
  location            = each.value.rglocation
  tags = merge(local.common_tags,
    tomap({
      "Name" = "${each.value.rgname}"
    })
  )
}

resource "azurerm_virtual_network" "mozilla1" {
  for_each            = var.mozilla1
  name                = "vn-${each.value.rgname}"
  resource_group_name = azurerm_resource_group.mozilla1[each.key].name
  location            = each.value.rglocation
  address_space       = ["10.0.0.0/23"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  tags = merge(local.common_tags,
    tomap({
      "Name" = "${each.value.rgname}"
    })
  )
  subnet {
    name           = "sn-${each.value.rgname}"
    address_prefix = "10.0.0.0/23"
    security_group = azurerm_network_security_group.mozilla1[each.key].id
  }
}
