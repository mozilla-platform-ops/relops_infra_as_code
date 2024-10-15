resource "azurerm_resource_group" "this" {
  name     = "rg-azure-cost-mgmt"
  location = "East US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-azure-cost-mgmt"
    })
  )
}

# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "this" {
  name                     = "safinopsdata"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = "East us"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "safinopsdata"
    })
  )
}