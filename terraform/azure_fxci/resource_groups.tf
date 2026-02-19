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

  tags = {
    "Name"             = "ronin-puppet-test-kitchen"
    "owner"            = "relops@mozilla.com"
    "owner_email"      = "mcornmesser@mozilla.com"
    "production_state" = "production"
    "project_name"     = "azure_fxci"
    "provisioner"      = "test-kitchen-azurerm"
    "source_repo_url"  = "https://github.com/mozilla-platform-ops/relops_infra_as_code"
    "terraform"        = "true"
  }
}
