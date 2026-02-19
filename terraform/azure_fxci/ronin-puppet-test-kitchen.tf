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
