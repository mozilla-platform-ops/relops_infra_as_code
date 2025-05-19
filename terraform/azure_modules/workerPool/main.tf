resource "azurerm_virtual_network" "this" {
  name                = var.azurerm_virtual_network_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space
  dns_servers         = var.vnet_dns_servers
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  name                 = var.azurerm_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.subnet_address_prefixes
}

resource "azurerm_network_security_group" "this" {
  name                = var.azurerm_network_security_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_public_ip_prefix" "this" {
  name                = var.azurerm_public_ip_prefix_name
  resource_group_name = var.resource_group_name
  location            = var.location
  prefix_length       = 28
  tags                = var.tags
}

resource "azurerm_public_ip" "this" {
  name                = var.azurerm_public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "this" {
  name                    = var.nat_gateway_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  idle_timeout_in_minutes = 4
  sku_name                = "Standard"
  tags                    = var.tags
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
  name                            = replace("${var.azurerm_storage_account_name}", "/\\W|_|\\s/", "")
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = true
  account_replication_type        = "GRS"
  min_tls_version                 = "TLS1_2"
  tags                            = var.tags
  identity {
    type = "SystemAssigned"
  }
}
