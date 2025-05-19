locals {
  #provisioner = "gecko-t"
  location = "ukwest"
  map      = yamldecode(file("${path.module}/config.yaml"))
  # Alternative approaches:
  # map = yamldecode(file("${path.root}/path/to/config.yaml"))
  # map = yamldecode(file("../config.yaml"))
  tags = {
    Provisioner = "gecko-t"
    Terraform   = true
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.location}-${local.map.provisioner}"
  location = local.location
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${local.location}-${local.map.provisioner}"
  resource_group_name = azurerm_resource_group.this.name
  location            = local.location
  address_space       = local.map.vnet_address_space
  dns_servers         = local.map.dns_servers
  tags                = local.tags
}

resource "azurerm_subnet" "this" {
  name                 = "sn-${local.location}-${local.map.provisioner}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = local.map.subnet_address_prefixes
}

resource "azurerm_network_security_group" "this" {
  name                = "nsg-${local.location}-${local.map.provisioner}"
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_public_ip_prefix" "this" {
  name                = "ippre-${local.location}-${local.map.provisioner}"
  resource_group_name = azurerm_resource_group.this.name
  location            = local.location
  prefix_length       = 28
  tags                = local.tags
}

resource "azurerm_public_ip" "this" {
  name                = "pip-${local.location}-${local.map.provisioner}"
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_nat_gateway" "this" {
  name                    = "ng-${local.location}-${local.map.provisioner}"
  location                = local.location
  resource_group_name     = azurerm_resource_group.this.name
  idle_timeout_in_minutes = 4
  sku_name                = "Standard"
  tags                    = local.tags
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "this" {
  nat_gateway_id      = azurerm_nat_gateway.this.id
  public_ip_prefix_id = azurerm_public_ip_prefix.this.id
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  nat_gateway_id = azurerm_nat_gateway.this.id
  subnet_id      = azurerm_subnet.this.id
}

resource "azurerm_storage_account" "this" {
  name                            = replace("st-${local.location}-${local.map.provisioner}", "/\\W|_|\\s/", "")
  resource_group_name             = azurerm_resource_group.this.name
  location                        = local.location
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = true
  account_replication_type        = "GRS"
  min_tls_version                 = "TLS1_2"
  tags                            = local.tags
  identity {
    type = "SystemAssigned"
  }
}
