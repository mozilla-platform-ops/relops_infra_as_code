resource "azurerm_resource_group" "devloaner" {
  for_each = var.devloaner
  name     = "rg-${each.value.rgname}"
  location = each.value.rglocation
  tags = merge(local.common_tags,
    tomap({
      "Name" = "${each.value.rgname}"
    })
  )
}

resource "azurerm_storage_account" "devloaner" {
  for_each                         = var.devloaner
  name                             = replace("sa${each.value.rgname}", "/\\W|_|\\s/", "")
  resource_group_name              = azurerm_resource_group.devloaner[each.key].name
  location                         = each.value.rglocation
  cross_tenant_replication_enabled = true
  account_replication_type         = "GRS"
  account_tier                     = "Standard"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "${each.value.rgname}"
    })
  )
}

resource "azurerm_network_security_group" "devloaner" {
  for_each            = var.devloaner
  name                = "nsg-${each.value.rgname}"
  resource_group_name = azurerm_resource_group.devloaner[each.key].name
  location            = each.value.rglocation
  tags = merge(local.common_tags,
    tomap({
      "Name" = "${each.value.rgname}"
    })
  )
}

resource "azurerm_virtual_network" "devloaner" {
  for_each            = var.devloaner
  name                = "vn-${each.value.rgname}"
  resource_group_name = azurerm_resource_group.devloaner[each.key].name
  location            = each.value.rglocation
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  tags = merge(local.common_tags,
    tomap({
      "Name" = "${each.value.rgname}"
    })
  )
  subnet {
    name             = "sn-${each.value.rgname}"
    address_prefixes = ["10.0.0.0/24"]
    security_group   = azurerm_network_security_group.devloaner[each.key].id
  }
}
