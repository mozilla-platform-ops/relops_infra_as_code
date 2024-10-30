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
data "azurerm_resource_group" "hgbundle" {
  for_each = local.regions
  name     = "rg-${each.value}-hgbundle"
}

resource "azuread_application" "hgbundle" {
  display_name = "moz_hgbundle"
  owners       = [data.azuread_user.jmoss.id]
}

resource "azuread_service_principal" "hgbundle" {
  application_id = azuread_application.hgbundle.application_id
}

resource "azurerm_role_assignment" "hgbundle" {
  for_each             = local.regions
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.hgbundle.object_id
  scope                = data.azurerm_resource_group.hgbundle[each.key].id
}
