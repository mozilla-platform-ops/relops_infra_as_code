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
resource "azurerm_subscription_cost_management_export" "actual" {
  name                         = "azure-infrasec_actual"
  subscription_id              = "/subscriptions/9b9774fb-67f1-45b7-830f-aafe07a94396"
  recurrence_type              = "Daily"
  recurrence_period_start_date = "2025-09-02T00:00:00Z"
  recurrence_period_end_date   = "2050-02-01T00:00:00Z"
  #file_format                  = "Csv"

  export_data_storage_location {
    container_id     = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/resourceGroups/rg-azure-cost-mgmt/providers/Microsoft.Storage/storageAccounts/safinopsdata/blobServices/default/containers/cost-management"
    root_folder_path = "azure_infrasec_daily_actual"
  }

  export_data_options {
    type       = "ActualCost"
    time_frame = "WeekToDate"
  }
}

resource "azurerm_subscription_cost_management_export" "amortized" {
  name                         = "azure-infrasec_amortized"
  subscription_id              = "/subscriptions/9b9774fb-67f1-45b7-830f-aafe07a94396"
  recurrence_type              = "Daily"
  recurrence_period_start_date = "2025-09-02T00:00:00Z"
  recurrence_period_end_date   = "2050-02-01T00:00:00Z"
  #file_format                  = "Csv"

  export_data_storage_location {
    container_id     = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/resourceGroups/rg-azure-cost-mgmt/providers/Microsoft.Storage/storageAccounts/safinopsdata/blobServices/default/containers/cost-management"
    root_folder_path = "azure_infrasec_daily_amortized"
  }

  export_data_options {
    type       = "AmortizedCost"
    time_frame = "WeekToDate"
  }
}
