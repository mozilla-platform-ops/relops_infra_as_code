# Adding
# A single blob supports up to 500 requests per second.
# If you have multiple clients that need to read the same blob and you might exceed this limit, then consider using a block blob storage account.
# A block blob storage account provides a higher request rate, or I/O operations per second (IOPS).

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
  ## Remove Removes any non-word characters, underscores, or whitespace from the concatenated string & limit to 24 characters
  name                     = substr(replace("mozhg${each.value}", "/\\W|_|\\s/", ""), 0, 24)
  resource_group_name      = azurerm_resource_group.hgbundle[each.value].name
  account_replication_type = "LRS"
  location                 = each.value
  account_tier             = "Premium"
  tags                     = local.tags
  account_kind             = "BlockBlobStorage"
  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "hgbundle" {
  for_each              = local.regions
  name                  = "hgbundle"
  storage_account_name  = azurerm_storage_account.hgbundle[each.value].name
  container_access_type = "container"
}

resource "azurerm_storage_management_policy" "hgbundle" {
  for_each           = local.regions
  storage_account_id = azurerm_storage_account.hgbundle[each.value].id
  rule {
    name    = "delete-old-hgbundle"
    enabled = true
    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["hgbundle/*"]
    }
    actions {
      base_blob {
        delete_after_days_since_creation_greater_than = 7
      }
    }
  }
}
