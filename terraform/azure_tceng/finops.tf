resource "azapi_resource" "tceng_cost_export_actual" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "taskcluster-daily_actual"
  parent_id = "/subscriptions/8a205152-b25a-417f-a676-80465535a6c9"

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
          rootFolderPath = "taskcluster"
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

resource "azapi_resource" "tceng_cost_export_amortized" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "taskcluster-daily_amortized"
  parent_id = "/subscriptions/8a205152-b25a-417f-a676-80465535a6c9"

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
          rootFolderPath = "taskcluster"
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
