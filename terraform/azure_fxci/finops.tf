## Creating one storage account for all cost data exports

import {
  to = azapi_resource.fxci_cost_export_actual
  id = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/providers/Microsoft.CostManagement/exports/fxci_daily_actual"
}

import {
  to = azapi_resource.fxci_cost_export_amortized
  id = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/providers/Microsoft.CostManagement/exports/fxci_daily_amortized"
}

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

resource "azapi_resource" "fxci_cost_export_actual" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "fxci_daily_actual"
  parent_id = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      schedule = {
        status     = "Active"
        recurrence = "Daily"
        recurrencePeriod = {
          from = "2024-03-21T00:00:00Z"
          to   = "2050-02-01T00:00:00Z"
        }
      }
      format                = "Csv"
      compressionMode       = "None"
      dataOverwriteBehavior = "CreateNewReport"
      deliveryInfo = {
        destination = {
          resourceId     = azurerm_storage_account.this.id
          container      = "cost-management"
          rootFolderPath = "fxci_daily"
        }
      }
      partitionData = true
      definition = {
        type      = "ActualCost"
        timeframe = "MonthToDate"
        dataSet = {
          granularity = "Daily"
          configuration = {
            columns = []
          }
        }
      }
    }
  }
}

resource "azapi_resource" "fxci_cost_export_amortized" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "fxci_daily_amortized"
  parent_id = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      schedule = {
        status     = "Active"
        recurrence = "Daily"
        recurrencePeriod = {
          from = "2024-03-21T00:00:00Z"
          to   = "2050-02-01T00:00:00Z"
        }
      }
      format                = "Csv"
      compressionMode       = "None"
      dataOverwriteBehavior = "CreateNewReport"
      deliveryInfo = {
        destination = {
          resourceId     = azurerm_storage_account.this.id
          container      = "cost-management"
          rootFolderPath = "fxci_daily"
        }
      }
      partitionData = true
      definition = {
        type      = "AmortizedCost"
        timeframe = "MonthToDate"
        dataSet = {
          granularity = "Daily"
          configuration = {
            columns = []
          }
        }
      }
    }
  }
}
