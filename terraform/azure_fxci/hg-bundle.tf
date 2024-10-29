locals {
  tags = {
    terraform        = "true"
    project_name     = "hgbundle"
    production_state = var.tag_production_state
    owner_email      = "relops@mozilla.com"
    source_repo_url  = "https://github.com/mozilla-platform-ops/relops_infra_as_code"
  }
  regions = toset([
    "canadacentral",
    "centralindia",
    "centralus",
    "eastus",
    "eastus2",
    "northcentralus",
    "northeurope",
    "southindia",
    "westus",
    "westus2",
    "westus3",
  ])
}

## Create storage accounts for each region
resource "azurerm_resource_group" "hgbundle" {
  for_each = local.regions
  name     = "rg-${each.value}-hgbundle"
  location = each.value
  tags     = local.tags
}

resource "azurerm_storage_account" "hgbundle" {
  for_each = local.regions
  #name                     = "mozhgazure${each.value}"
  name                     = replace("mozhgazure${each.value}", "/\\W|_|\\s/", "")
  resource_group_name      = azurerm_resource_group.hgbundle[each.value].name
  account_replication_type = "LRS"
  location                 = each.value
  account_tier             = "Standard"
  tags                     = local.tags
}
