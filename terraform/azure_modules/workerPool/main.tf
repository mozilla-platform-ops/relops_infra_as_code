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
  dynamic "security_rule" {
    for_each = var.nsg_security_rules
    content {
      name                       = each.value.name
      priority                   = each.value.priority
      direction                  = each.value.direction
      access                     = each.value.access
      protocol                   = each.value.protocol
      source_port_range          = each.value.source_port_range
      destination_port_ranges    = each.value.destination_port_ranges
      source_address_prefixes    = each.value.source_address_prefixes
      destination_address_prefix = each.value.destination_address_prefix
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_public_ip_prefix" "this" {
  name                = var.azurerm_public_ip_prefix_name
  resource_group_name = var.resource_group_name
  location            = var.location
  prefix_length       = var.azurerm_public_ip_prefix_length
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
  # Azure storage account names must be between 3 and 24 characters, contain only lowercase letters and numbers, 
  # and must not contain special characters or spaces. This regex removes disallowed characters, converts the name 
  # to lowercase, and truncates it to 24 characters to ensure compliance.
  name                            = substr(lower(replace("${var.azurerm_storage_account_name}", "[^a-z0-9]", "")), 0, 24)
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
