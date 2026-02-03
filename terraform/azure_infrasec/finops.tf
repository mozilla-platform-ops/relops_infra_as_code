resource "azapi_resource" "azure_infrasec_cost_export_actual" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "azure-infrasec_actual"
  parent_id = "/subscriptions/9b9774fb-67f1-45b7-830f-aafe07a94396"

  body = {
    properties = {
      schedule = {
        status     = "Active"
        recurrence = "Daily"
        recurrencePeriod = {
          from = "2025-09-02T00:00:00Z"
          to   = "2050-02-01T00:00:00Z"
        }
      }
      format                = "Csv"
      compressionMode       = "None"
      dataOverwriteBehavior = "CreateNewReport"
      deliveryInfo = {
        destination = {
          type           = "AzureBlob"
          resourceId     = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/resourceGroups/rg-azure-cost-mgmt/providers/Microsoft.Storage/storageAccounts/safinopsdata"
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
          configuration = {
            columns     = []
            dataVersion = "2021-10-01"
            filters     = []
          }
        }
      }
    }
  }
}

resource "azapi_resource" "azure_infrasec_cost_export_amortized" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "azure-infrasec_amortized"
  parent_id = "/subscriptions/9b9774fb-67f1-45b7-830f-aafe07a94396"

  body = {
    properties = {
      schedule = {
        status     = "Active"
        recurrence = "Daily"
        recurrencePeriod = {
          from = "2025-09-02T00:00:00Z"
          to   = "2050-02-01T00:00:00Z"
        }
      }
      format                = "Csv"
      compressionMode       = "None"
      dataOverwriteBehavior = "CreateNewReport"
      deliveryInfo = {
        destination = {
          type           = "AzureBlob"
          resourceId     = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/resourceGroups/rg-azure-cost-mgmt/providers/Microsoft.Storage/storageAccounts/safinopsdata"
          container      = "cost-management"
          rootFolderPath = "azure_infrasec_daily_amortized"
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
            dataVersion = "2021-10-01"
            filters     = []
          }
        }
      }
    }
  }
}
