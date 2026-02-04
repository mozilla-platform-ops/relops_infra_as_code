resource "azapi_resource" "trusted_fxci_cost_export_actual" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "trusted_fxci_daily_actual"
  parent_id = "/subscriptions/a30e97ab-734a-4f3b-a0e4-c51c0bff0701"

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      schedule = {
        status     = "Active"
        recurrence = "Daily"
        recurrencePeriod = {
          from = "2024-04-09T00:00:00Z"
          to   = "2050-02-01T00:00:00Z"
        }
      }
      format                = "Csv"
      compressionMode       = "None"
      dataOverwriteBehavior = "OverwritePreviousReport"
      exportDescription     = ""
      deliveryInfo = {
        destination = {
          type           = "AzureBlob"
          resourceId     = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/resourceGroups/rg-azure-cost-mgmt/providers/Microsoft.Storage/storageAccounts/safinopsdata"
          container      = "cost-management"
          rootFolderPath = "trusted_fxci_daily"
        }
      }
      partitionData = true
      definition = {
        type      = "ActualCost"
        timeframe = "MonthToDate"
        dataSet = {
          granularity = "Daily"
          configuration = {
            columns     = []
            dataVersion = "2023-05-01"
            filters     = []
          }
        }
      }
    }
  }
}

resource "azapi_resource" "trusted_fxci_cost_export_amortized" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "trusted_fxci_daily_amortized"
  parent_id = "/subscriptions/a30e97ab-734a-4f3b-a0e4-c51c0bff0701"

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      schedule = {
        status     = "Active"
        recurrence = "Daily"
        recurrencePeriod = {
          from = "2024-04-09T00:00:00Z"
          to   = "2050-02-01T00:00:00Z"
        }
      }
      format                = "Csv"
      compressionMode       = "None"
      dataOverwriteBehavior = "OverwritePreviousReport"
      exportDescription     = ""
      deliveryInfo = {
        destination = {
          type           = "AzureBlob"
          resourceId     = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/resourceGroups/rg-azure-cost-mgmt/providers/Microsoft.Storage/storageAccounts/safinopsdata"
          container      = "cost-management"
          rootFolderPath = "trusted_fxci_daily"
        }
      }
      partitionData = true
      definition = {
        type      = "AmortizedCost"
        timeframe = "MonthToDate"
        dataSet = {
          granularity = "Daily"
          configuration = {
            columns     = []
            dataVersion = "2023-05-01"
            filters     = []
          }
        }
      }
    }
  }
}
