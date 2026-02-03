resource "azapi_resource" "fx_non_ci_cost_export_actual" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "fx_non_ci_actual"
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
          rootFolderPath = "fx_non_ci"
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

resource "azapi_resource" "fx_non_ci_cost_export_amortized" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "fx_non_ci_amortized"
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
          rootFolderPath = "fx_non_ci"
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
