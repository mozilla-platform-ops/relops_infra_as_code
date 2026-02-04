resource "azapi_resource" "taskcluster_cost_export_actual" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "taskcluster-daily_actual"
  parent_id = "/subscriptions/8a205152-b25a-417f-a676-80465535a6c9"

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      schedule = {
        status     = "Active"
        recurrence = "Daily"
        recurrencePeriod = {
          from = "2024-09-03T00:00:00Z"
          to   = "2050-02-01T00:00:00Z"
        }
      }
      format                = "Csv"
      compressionMode       = "gzip"
      dataOverwriteBehavior = "OverwritePreviousReport"
      exportDescription     = ""
      deliveryInfo = {
        destination = {
          type           = "AzureBlob"
          resourceId     = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/resourceGroups/rg-azure-cost-mgmt/providers/Microsoft.Storage/storageAccounts/safinopsdata"
          container      = "cost-management"
          rootFolderPath = "taskcluster"
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

resource "azapi_resource" "taskcluster_cost_export_amortized" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "taskcluster-daily_amortized"
  parent_id = "/subscriptions/8a205152-b25a-417f-a676-80465535a6c9"

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      schedule = {
        status     = "Active"
        recurrence = "Daily"
        recurrencePeriod = {
          from = "2024-09-03T00:00:00Z"
          to   = "2050-02-01T00:00:00Z"
        }
      }
      format                = "Csv"
      compressionMode       = "gzip"
      dataOverwriteBehavior = "OverwritePreviousReport"
      exportDescription     = ""
      deliveryInfo = {
        destination = {
          type           = "AzureBlob"
          resourceId     = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/resourceGroups/rg-azure-cost-mgmt/providers/Microsoft.Storage/storageAccounts/safinopsdata"
          container      = "cost-management"
          rootFolderPath = "taskcluster"
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
