resource "azurerm_resource_group" "relops_terraform" {
  name     = "relops_terraform"
  location = "West US"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "relops_terraform"
    })
  )
}

resource "azurerm_resource_group" "windows7" {
  name     = "rg-north-central-us-windows7"
  location = "North Central US"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "relops_terraform"
    })
  )
}

resource "azurerm_resource_group" "ronin_puppet_test_kitchen" {
  name     = "ronin-puppet-test-kitchen"
  location = "East US 2"

  tags = merge(local.common_tags,
    tomap({
      "Name"        = "ronin-puppet-test-kitchen"
      "owner"       = "relops@mozilla.com"
      "provisioner" = "test-kitchen-azurerm"
    })
  )
}

