data "azurerm_resource_group" "example" {
  name     = "rg-azure-cost-mgmt"
  location = "East US"
}

data "azurerm_storage_account" "example" {
  name                = "safinopsdata"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_billing_account_cost_management_export" "tceng" {
  name                         = "tceng_daily_actual"
  billing_account_id           = "example"
  recurrence_type              = "Monthly"
  recurrence_period_start_date = "2020-08-18T00:00:00Z"
  recurrence_period_end_date   = "2020-09-18T00:00:00Z"

  export_data_storage_location {
    container_id     = azurerm_storage_container.example.resource_manager_id
    root_folder_path = "/root/updated"
  }

  export_data_options {
    type       = "Usage"
    time_frame = "WeekToDate"
  }
}