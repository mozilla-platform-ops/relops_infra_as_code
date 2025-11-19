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
  name                     = "safinopsdatafirefoxnonci"
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

## Azure Cost Exports for Azure Infrastructure Security Subscription
resource "azapi_resource" "azure_infrasec_cost_export_actual" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "azure-firefox-nonci_actual"
  parent_id = "/subscriptions/0a420ff9-bc77-4475-befc-a05071fc92ec"

  body = {
    properties = {
      schedule = {
        status     = "Active"
        recurrence = "Daily"
        recurrencePeriod = {
          from = "2025-09-02T00:00:00.000Z"
          to   = "2050-02-01T00:00:00.000Z"
        }
      }
      format = "Csv"
      compressionMode = "None"
      deliveryInfo = {
        destination = {
          resourceId     = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/resourceGroups/rg-azure-cost-mgmt/providers/Microsoft.Storage/storageAccounts/safinopsdata"
          container      = "cost-management"
          rootFolderPath = "azure_firefox_nonci_daily_actual"
        }
      }
      partitionData = true
      definition = {
        type      = "ActualCost"
        timeframe = "MonthToDate"
        dataSet = {
          granularity = "Daily"
        }
      }
    }
  }
}

resource "azapi_resource" "azure_infrasec_cost_export_amortized" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "azure-firefox-nonci_amortized"
  parent_id = "/subscriptions/0a420ff9-bc77-4475-befc-a05071fc92ec"

  body = {
    properties = {
      schedule = {
        status     = "Active"
        recurrence = "Daily"
        recurrencePeriod = {
          from = "2025-09-02T00:00:00.000Z"
          to   = "2050-02-01T00:00:00.000Z"
        }
      }
      format = "Csv"
      compressionMode = "None"
      deliveryInfo = {
        destination = {
          resourceId     = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/resourceGroups/rg-azure-cost-mgmt/providers/Microsoft.Storage/storageAccounts/safinopsdata"
          container      = "cost-management"
          rootFolderPath = "azure_firefox_nonci_daily_amortized"
        }
      }
      partitionData = true
      definition = {
        type      = "AmortizedCost"
        timeframe = "MonthToDate"
        dataSet = {
          granularity = "Daily"
        }
      }
    }
  }
}
