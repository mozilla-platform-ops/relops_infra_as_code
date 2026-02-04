# Cost exports for billing-scoped resources (invoice sections, billing profiles)
# These are not tied to a specific subscription

locals {
  # Billing hierarchy
  billing_account_id         = "05ef9068-c74c-54a9-5b8f-82f7fb8b32cd:6e104178-9e3c-470c-9787-8ef53f372665_2019-05-31"
  mozilla_billing_profile_id = "GRUW-TLBL-BG7-PGB"

  # Invoice sections under mozilla billing profile
  anonym_invoice_section_id = "RUDC-GV4R-PJA-PGB"
}

# Storage account for cost exports (managed in azure_fxci)
data "azurerm_storage_account" "finops" {
  name                = "safinopsdata"
  resource_group_name = "rg-azure-cost-mgmt"
}

import {
  to = azapi_resource.anonym_cost_export_actual
  id = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.mozilla_billing_profile_id}/invoiceSections/${local.anonym_invoice_section_id}/providers/Microsoft.CostManagement/exports/anonym_daily-actual-cost"
}

import {
  to = azapi_resource.anonym_cost_export_amortized
  id = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.mozilla_billing_profile_id}/invoiceSections/${local.anonym_invoice_section_id}/providers/Microsoft.CostManagement/exports/anonym-amortized-cost"
}

# Anonym invoice section - Actual Cost export
resource "azapi_resource" "anonym_cost_export_actual" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "anonym_daily-actual-cost"
  parent_id = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.mozilla_billing_profile_id}/invoiceSections/${local.anonym_invoice_section_id}"

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      schedule = {
        status     = "Active"
        recurrence = "Daily"
        recurrencePeriod = {
          from = "2024-10-01T00:00:00Z"
          to   = "2050-02-01T00:00:00Z"
        }
      }
      format                = "Csv"
      compressionMode       = "None"
      dataOverwriteBehavior = "CreateNewReport"
      deliveryInfo = {
        destination = {
          type           = "AzureBlob"
          resourceId     = data.azurerm_storage_account.finops.id
          container      = "cost-management"
          rootFolderPath = "anon_daily"
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

# Anonym invoice section - Amortized Cost export
resource "azapi_resource" "anonym_cost_export_amortized" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = "anonym-amortized-cost"
  parent_id = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.mozilla_billing_profile_id}/invoiceSections/${local.anonym_invoice_section_id}"

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      schedule = {
        status     = "Active"
        recurrence = "Daily"
        recurrencePeriod = {
          from = "2024-10-01T00:00:00Z"
          to   = "2050-02-01T00:00:00Z"
        }
      }
      format                = "Csv"
      compressionMode       = "None"
      dataOverwriteBehavior = "CreateNewReport"
      deliveryInfo = {
        destination = {
          type           = "AzureBlob"
          resourceId     = data.azurerm_storage_account.finops.id
          container      = "cost-management"
          rootFolderPath = "anon_daily_amortized"
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
