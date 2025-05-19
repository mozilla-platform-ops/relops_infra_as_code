locals {
  location       = "East US 2"
  location_short = "eus2"
  map            = yamldecode(file("${path.module}/config.yaml"))
  tags = {
    Provisioner = "gecko-t"
    Terraform   = true
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.location_short}-${local.map.provisioner}"
  location = local.location
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = [local.location_short, local.map.provisioner]
}

module "workerPool" {
  source                              = "../../../azure_modules/workerPool"
  location                            = local.location
  azurerm_virtual_network_name        = module.naming.virtual_network.name
  azurerm_subnet_name                 = module.naming.subnet.name
  resource_group_name                 = azurerm_resource_group.this.name
  azurerm_network_security_group_name = module.naming.network_security_group.name
  azurerm_public_ip_prefix_name       = module.naming.public_ip_prefix.name
  nat_gateway_name                    = module.naming.nat_gateway.name
  azurerm_public_ip_name              = module.naming.public_ip.name
  azurerm_storage_account_name        = module.naming.storage_account.name
  vnet_address_space                  = local.map.vnet_address_space
  vnet_dns_servers                    = local.map.vnet_dns_servers
  subnet_address_prefixes             = local.map.subnet_address_prefixes
  provisioner                         = local.map.provisioner
  tags                                = local.tags
}
