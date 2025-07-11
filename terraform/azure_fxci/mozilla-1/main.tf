locals {
  location_map = {
    #"Canada Central"   = "canada-central"
    #"Central India"    = "central-india"
    "Central US"       = "central-us"
    #"East US"          = "east-us"
    "East US 2"        = "east-us-2"
    "North Central US" = "north-central-us"
    #"North Europe"     = "north-europe"
    #"South India"      = "south-india"
    #"UK South"         = "uk-south"
    #"West US"          = "west-us"
    "West US 2"        = "west-us-2"
    "West US 3"        = "west-us-3"
  }

  config = yamldecode(file("../config.yaml"))
  tags = {
    terraform       = "true"
    source_repo_url = "https://github.com/mozilla-platform-ops/relops_infra_as_code"
  }
  provisioner = "mozilla-1"
  provisioner_short = "moz1"
}

resource "azurerm_resource_group" "this" {
  for_each = local.location_map
  name     = "rg2-${each.value}-${local.provisioner}"
  location = each.key
}

module "mozilla-1" {
  for_each                            = local.location_map
  source                              = "../../azure_modules/workerPool"
  location                            = each.key
  azurerm_virtual_network_name        = "vn2-${each.value}-${local.provisioner}"
  azurerm_subnet_name                 = "sn2-${each.value}-${local.provisioner}"
  resource_group_name                 = azurerm_resource_group.this[each.key].name
  azurerm_network_security_group_name = "nsg2-${each.value}-${local.provisioner}"
  azurerm_public_ip_prefix_name       = "ippre2-${each.value}-${local.provisioner}"
  nat_gateway_name                    = "ng2-${each.value}-${local.provisioner}"
  azurerm_storage_account_name        = "sa2${each.value}-${local.provisioner_short}"
  vnet_address_space                  = local.config.defaults.vnet_address_space
  vnet_dns_servers                    = local.config.defaults.vnet_dns_servers
  subnet_address_prefixes             = local.config.defaults.subnet_address_prefixes
  provisioner                         = local.provisioner
  tags                                = local.tags
  nsg_security_rules                  = []
  depends_on                          = [azurerm_resource_group.this]
}
