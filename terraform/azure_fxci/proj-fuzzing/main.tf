locals {
  location_map = {
    "Central US" = "central-us"
    "East US"    = "east-us"
    "West US 2"  = "west-us-2"
  }

  config = yamldecode(file("../config.yaml"))
  tags = {
    terraform       = "true"
    source_repo_url = "https://github.com/mozilla-platform-ops/relops_infra_as_code"
  }
  provisioner = "proj-fuzzing"

  # Mirrors the TCeng RDP_Only NSGs used by current Windows image resources.
  rdp_source_address_prefixes = [
    "63.245.208.133",
    "63.245.208.132",
    "185.155.182.210",
  ]

  nsg_security_rules = [
    {
      name                       = "AllowCidrBlockRDPInbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["3389"]
      source_address_prefixes    = local.rdp_source_address_prefixes
      destination_address_prefix = "*"
    }
  ]
}

resource "azurerm_resource_group" "nongw" {
  for_each = local.location_map
  name     = "rg-${each.value}-${local.provisioner}"
  location = each.key
  tags     = local.tags
}

module "proj_fuzzing_nogw" {
  for_each                            = local.location_map
  source                              = "../../azure_modules/workerPool_v1"
  location                            = each.key
  azurerm_virtual_network_name        = "vn-${each.value}-${local.provisioner}"
  azurerm_subnet_name                 = "sn-${each.value}-${local.provisioner}"
  resource_group_name                 = azurerm_resource_group.nongw[each.key].name
  azurerm_network_security_group_name = "nsg-${each.value}-${local.provisioner}"
  azurerm_storage_account_name        = "sa${each.value}-${local.provisioner}"
  vnet_address_space                  = local.config.defaults.vnet_address_space
  vnet_dns_servers                    = local.config.defaults.vnet_dns_servers
  subnet_address_prefixes             = local.config.defaults.subnet_address_prefixes
  provisioner                         = local.provisioner
  tags                                = local.tags
  nsg_security_rules                  = local.nsg_security_rules
  depends_on                          = [azurerm_resource_group.nongw]
}
