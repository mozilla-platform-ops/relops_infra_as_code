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

## Azure Cost Exports for Azure Infrastructure Security Subscription
resource "azapi_resource" "azure_zero_din_cost_export_actual" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "azure-infrasec_actual"
  parent_id = "/subscriptions/e1cb04e4-3788-471a-881f-385e66ad80ab"

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
          resourceId     = "/subscriptions/e1cb04e4-3788-471a-881f-385e66ad80ab/resourceGroups/rg-azure-cost-mgmt/providers/Microsoft.Storage/storageAccounts/safinopsdata"
          container      = "cost-management"
          rootFolderPath = "azure_infrasec_daily_actual"
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

resource "azapi_resource" "azure_zero_din_cost_export_amortized" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "azure-infrasec_amortized"
  parent_id = "/subscriptions/e1cb04e4-3788-471a-881f-385e66ad80ab"

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
          resourceId     = "/subscriptions/e1cb04e4-3788-471a-881f-385e66ad80ab/resourceGroups/rg-azure-cost-mgmt/providers/Microsoft.Storage/storageAccounts/safinopsdata"
          container      = "cost-management"
          rootFolderPath = "azure_zero_din_daily_amortized"
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
