# Cost exports for billing-scoped resources (invoice sections, billing profiles)
# These are not tied to a specific subscription

locals {
  # Billing hierarchy
  billing_account_id         = "05ef9068-c74c-54a9-5b8f-82f7fb8b32cd:6e104178-9e3c-470c-9787-8ef53f372665_2019-05-31"
  mozilla_billing_profile_id = "GRUW-TLBL-BG7-PGB"

  # Invoice sections under mozilla billing profile
  anonym_invoice_section_id  = "RUDC-GV4R-PJA-PGB"
  mozilla_invoice_section_id = "VVEC-AWWS-PJA-PGB"

  # US Corp Card billing profile
  uscorpcard_billing_profile_id = "F6IO-6MX2-BG7-PGB"
  uscorpcard_invoice_section_id = "C7BX-N2MV-PJA-PGB"
}

# Storage account for cost exports (managed in azure_fxci)
data "azurerm_storage_account" "finops" {
  name                = "safinopsdata"
  resource_group_name = "rg-azure-cost-mgmt"
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

module "anonym_focusCost" {
  source = "../azure_modules/costExport"

  columns                 = []
  compression_mode        = "None"
  container_name          = "cost-management"
  cost_type               = "FocusCost"
  data_overwrite_behavior = "CreateNewReport"
  data_version            = "1.0r2"
  export_description      = "Anonym Focus Cost Export. https://mozilla-hub.atlassian.net/browse/RELOPS-2174"
  export_name             = "anonym_focuscost_daily"
  format                  = "Csv"
  granularity             = "Daily"
  parent_id               = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.mozilla_billing_profile_id}/invoiceSections/${local.anonym_invoice_section_id}"
  partition_data          = true
  recurrence              = "Daily"
  recurrence_period_from  = "2026-02-05T00:00:00Z"
  recurrence_period_to    = "2050-02-05T00:00:00Z"
  root_folder_path        = "anonym_focuscost"
  status                  = "Active"
  storage_account_id      = data.azurerm_storage_account.finops.id
  timeframe               = "MonthToDate"
}

module "mozilla_reservationDetails" {
  source = "../azure_modules/costExport"

  columns                 = []
  compression_mode        = "None"
  container_name          = "cost-management"
  cost_type               = "ReservationDetails"
  data_overwrite_behavior = "CreateNewReport"
  data_version            = "2023-03-01"
  export_description      = "Mozilla Reservation Details Export. https://mozilla-hub.atlassian.net/browse/RELOPS-2174"
  export_name             = "mozilla_reservation_details_daily"
  format                  = "Csv"
  granularity             = "Daily"
  parent_id               = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.mozilla_billing_profile_id}"
  partition_data          = true
  recurrence              = "Daily"
  recurrence_period_from  = "2026-02-05T00:00:00Z"
  recurrence_period_to    = "2050-02-05T00:00:00Z"
  root_folder_path        = "mozilla_reservation_details"
  status                  = "Active"
  storage_account_id      = data.azurerm_storage_account.finops.id
  timeframe               = "MonthToDate"
}

module "mozilla_reservationRecommendations" {
  source = "../azure_modules/costExport"

  columns                 = []
  compression_mode        = "None"
  container_name          = "cost-management"
  cost_type               = "ReservationRecommendations"
  data_overwrite_behavior = "CreateNewReport"
  data_version            = "2023-05-01"
  export_description      = "Mozilla Reservation Recommendations Export. https://mozilla-hub.atlassian.net/browse/RELOPS-2174"
  export_name             = "mozilla_reservation_recommendations_daily"
  format                  = "Csv"
  granularity             = null
  parent_id               = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.mozilla_billing_profile_id}"
  partition_data          = true
  recurrence              = "Daily"
  recurrence_period_from  = "2026-02-05T00:00:00Z"
  recurrence_period_to    = "2050-02-05T00:00:00Z"
  root_folder_path        = "mozilla_reservation_recommendations"
  status                  = "Active"
  storage_account_id      = data.azurerm_storage_account.finops.id
  timeframe               = "MonthToDate"
}

module "mozilla_reservationTransactions" {
  source = "../azure_modules/costExport"

  columns                 = []
  compression_mode        = "None"
  container_name          = "cost-management"
  cost_type               = "ReservationTransactions"
  data_overwrite_behavior = "CreateNewReport"
  data_version            = "2023-05-01"
  export_description      = "Mozilla Reservation Transactions Export. https://mozilla-hub.atlassian.net/browse/RELOPS-2174"
  export_name             = "mozilla_reservation_transactions_daily"
  format                  = "Csv"
  granularity             = null
  parent_id               = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.mozilla_billing_profile_id}"
  partition_data          = true
  recurrence              = "Daily"
  recurrence_period_from  = "2026-02-05T00:00:00Z"
  recurrence_period_to    = "2050-02-05T00:00:00Z"
  root_folder_path        = "mozilla_reservation_transactions"
  status                  = "Active"
  storage_account_id      = data.azurerm_storage_account.finops.id
  timeframe               = "MonthToDate"
}

module "mozilla_focusCost" {
  source = "../azure_modules/costExport"

  columns                 = []
  compression_mode        = "None"
  container_name          = "cost-management"
  cost_type               = "FocusCost"
  data_overwrite_behavior = "CreateNewReport"
  data_version            = "1.0r2"
  export_description      = "Mozilla Focus Cost Export. https://mozilla-hub.atlassian.net/browse/RELOPS-2174"
  export_name             = "mozilla_focus_cost_daily"
  format                  = "Csv"
  granularity             = "Daily"
  parent_id               = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.mozilla_billing_profile_id}/invoiceSections/${local.mozilla_invoice_section_id}"
  partition_data          = true
  recurrence              = "Daily"
  recurrence_period_from  = "2026-02-05T00:00:00Z"
  recurrence_period_to    = "2050-02-05T00:00:00Z"
  root_folder_path        = "mozilla_focus_cost"
  status                  = "Active"
  storage_account_id      = data.azurerm_storage_account.finops.id
  timeframe               = "MonthToDate"
}

# US Corp Card invoice section - Actual Cost export
module "uscorpcard_actualCost" {
  source = "../azure_modules/costExport"

  columns                 = []
  compression_mode        = "None"
  container_name          = "cost-management"
  cost_type               = "ActualCost"
  data_overwrite_behavior = "CreateNewReport"
  data_version            = "2021-10-01"
  export_description      = "US Corp Card Actual Cost Export. https://mozilla-hub.atlassian.net/browse/RELOPS-2174"
  export_name             = "uscorpcard_actual_cost_daily"
  format                  = "Csv"
  granularity             = "Daily"
  parent_id               = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.uscorpcard_billing_profile_id}/invoiceSections/${local.uscorpcard_invoice_section_id}"
  partition_data          = true
  recurrence              = "Daily"
  recurrence_period_from  = "2026-02-05T00:00:00Z"
  recurrence_period_to    = "2050-02-05T00:00:00Z"
  root_folder_path        = "uscorpcard_actual_cost"
  status                  = "Active"
  storage_account_id      = data.azurerm_storage_account.finops.id
  timeframe               = "MonthToDate"
}

# US Corp Card invoice section - Amortized Cost export
module "uscorpcard_amortizedCost" {
  source = "../azure_modules/costExport"

  columns                 = []
  compression_mode        = "None"
  container_name          = "cost-management"
  cost_type               = "AmortizedCost"
  data_overwrite_behavior = "CreateNewReport"
  data_version            = "2021-10-01"
  export_description      = "US Corp Card Amortized Cost Export. https://mozilla-hub.atlassian.net/browse/RELOPS-2174"
  export_name             = "uscorpcard_amortized_cost_daily"
  format                  = "Csv"
  granularity             = "Daily"
  parent_id               = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.uscorpcard_billing_profile_id}/invoiceSections/${local.uscorpcard_invoice_section_id}"
  partition_data          = true
  recurrence              = "Daily"
  recurrence_period_from  = "2026-02-05T00:00:00Z"
  recurrence_period_to    = "2050-02-05T00:00:00Z"
  root_folder_path        = "uscorpcard_amortized_cost"
  status                  = "Active"
  storage_account_id      = data.azurerm_storage_account.finops.id
  timeframe               = "MonthToDate"
}

# US Corp Card invoice section - Focus Cost export
module "uscorpcard_focusCost" {
  source = "../azure_modules/costExport"

  columns                 = []
  compression_mode        = "None"
  container_name          = "cost-management"
  cost_type               = "FocusCost"
  data_overwrite_behavior = "CreateNewReport"
  data_version            = "1.0r2"
  export_description      = "US Corp Card Focus Cost Export. https://mozilla-hub.atlassian.net/browse/RELOPS-2174"
  export_name             = "uscorpcard_focus_cost_daily"
  format                  = "Csv"
  granularity             = "Daily"
  parent_id               = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.uscorpcard_billing_profile_id}/invoiceSections/${local.uscorpcard_invoice_section_id}"
  partition_data          = true
  recurrence              = "Daily"
  recurrence_period_from  = "2026-02-05T00:00:00Z"
  recurrence_period_to    = "2050-02-05T00:00:00Z"
  root_folder_path        = "uscorpcard_focus_cost"
  status                  = "Active"
  storage_account_id      = data.azurerm_storage_account.finops.id
  timeframe               = "MonthToDate"
}

# US Corp Card billing profile - Reservation Details export
module "uscorpcard_reservationDetails" {
  source = "../azure_modules/costExport"

  columns                 = []
  compression_mode        = "None"
  container_name          = "cost-management"
  cost_type               = "ReservationDetails"
  data_overwrite_behavior = "CreateNewReport"
  data_version            = "2023-03-01"
  export_description      = "US Corp Card Reservation Details Export. https://mozilla-hub.atlassian.net/browse/RELOPS-2174"
  export_name             = "uscorpcard_reservation_details_daily"
  format                  = "Csv"
  granularity             = "Daily"
  parent_id               = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.uscorpcard_billing_profile_id}"
  partition_data          = true
  recurrence              = "Daily"
  recurrence_period_from  = "2026-02-05T00:00:00Z"
  recurrence_period_to    = "2050-02-05T00:00:00Z"
  root_folder_path        = "uscorpcard_reservation_details"
  status                  = "Active"
  storage_account_id      = data.azurerm_storage_account.finops.id
  timeframe               = "MonthToDate"
}

# US Corp Card billing profile - Reservation Recommendations export
module "uscorpcard_reservationRecommendations" {
  source = "../azure_modules/costExport"

  columns                 = []
  compression_mode        = "None"
  container_name          = "cost-management"
  cost_type               = "ReservationRecommendations"
  data_overwrite_behavior = "CreateNewReport"
  data_version            = "2023-05-01"
  export_description      = "US Corp Card Reservation Recommendations Export. https://mozilla-hub.atlassian.net/browse/RELOPS-2174"
  export_name             = "uscorpcard_reservation_recommendations_daily"
  format                  = "Csv"
  granularity             = null
  parent_id               = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.uscorpcard_billing_profile_id}"
  partition_data          = true
  recurrence              = "Daily"
  recurrence_period_from  = "2026-02-05T00:00:00Z"
  recurrence_period_to    = "2050-02-05T00:00:00Z"
  root_folder_path        = "uscorpcard_reservation_recommendations"
  status                  = "Active"
  storage_account_id      = data.azurerm_storage_account.finops.id
  timeframe               = "MonthToDate"
}

# US Corp Card billing profile - Reservation Transactions export
module "uscorpcard_reservationTransactions" {
  source = "../azure_modules/costExport"

  columns                 = []
  compression_mode        = "None"
  container_name          = "cost-management"
  cost_type               = "ReservationTransactions"
  data_overwrite_behavior = "CreateNewReport"
  data_version            = "2023-05-01"
  export_description      = "US Corp Card Reservation Transactions Export. https://mozilla-hub.atlassian.net/browse/RELOPS-2174"
  export_name             = "uscorpcard_reservation_transactions_daily"
  format                  = "Csv"
  granularity             = null
  parent_id               = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.uscorpcard_billing_profile_id}"
  partition_data          = true
  recurrence              = "Daily"
  recurrence_period_from  = "2026-02-05T00:00:00Z"
  recurrence_period_to    = "2050-02-05T00:00:00Z"
  root_folder_path        = "uscorpcard_reservation_transactions"
  status                  = "Active"
  storage_account_id      = data.azurerm_storage_account.finops.id
  timeframe               = "MonthToDate"
}
