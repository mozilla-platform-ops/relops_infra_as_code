# Azure Cost Export Module

This Terraform module creates Azure Cost Management exports for billing accounts, subscriptions, resource groups, or other scopes.

## Features

- Support for all export types: ActualCost, AmortizedCost, and Usage
- Configurable schedule (Daily, Weekly, Monthly, Annually)
- Flexible export destination (Azure Blob Storage)
- Support for data partitioning
- Configurable granularity (Daily or Monthly)
- System-assigned managed identity

## Usage

### Basic Example (using defaults)

```hcl
module "cost_export" {
  source = "../../azure_modules/costExport"

  export_name = "my-daily-cost-export"
  parent_id   = "/subscriptions/12345678-1234-1234-1234-123456789012"

  delivery_info = {
    storage_account_id = azurerm_storage_account.example.id
    container          = "cost-management"
    root_folder_path   = "exports/daily"
  }
}
```

### Billing-Scoped Export Example

```hcl
locals {
  billing_account_id = "05ef9068-c74c-54a9-5b8f-82f7fb8b32cd:6e104178-9e3c-470c-9787-8ef53f372665_2019-05-31"
  billing_profile_id = "GRUW-TLBL-BG7-PGB"
  invoice_section_id = "RUDC-GV4R-PJA-PGB"
  parent_id          = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.billing_profile_id}/invoiceSections/${local.invoice_section_id}"
}

data "azurerm_storage_account" "finops" {
  name                = "safinopsdata"
  resource_group_name = "rg-azure-cost-mgmt"
}

# Actual Cost Export
module "actual_cost_export" {
  source = "../../azure_modules/costExport"

  export_name = "daily-actual-cost"
  parent_id   = local.parent_id

  delivery_info = {
    storage_account_id = data.azurerm_storage_account.finops.id
    container          = "cost-management"
    root_folder_path   = "actual_daily"
  }

  definition = {
    type      = "ActualCost"
    timeframe = "MonthToDate"
    data_set = {
      granularity = "Daily"
      configuration = {
        columns      = []
        data_version = "2023-05-01"
      }
    }
  }
}

# Amortized Cost Export
module "amortized_cost_export" {
  source = "../../azure_modules/costExport"

  export_name = "daily-amortized-cost"
  parent_id   = local.parent_id

  delivery_info = {
    storage_account_id = data.azurerm_storage_account.finops.id
    container          = "cost-management"
    root_folder_path   = "amortized_daily"
  }

  definition = {
    type      = "AmortizedCost"
    timeframe = "MonthToDate"
    data_set = {
      granularity = "Daily"
      configuration = {
        columns      = []
        data_version = "2023-05-01"
      }
    }
  }
}
```

### Advanced Example with Custom Configuration

```hcl
module "custom_export" {
  source = "../../azure_modules/costExport"

  export_name             = "weekly-export-compressed"
  parent_id               = "/subscriptions/12345678-1234-1234-1234-123456789012"
  format                  = "Csv"
  compression_mode        = "GZip"
  partition_data          = true
  data_overwrite_behavior = "OverwritePreviousReport"

  schedule = {
    status     = "Active"
    recurrence = "Weekly"
    recurrence_period = {
      from = "2024-01-01T00:00:00Z"
      to   = "2030-12-31T00:00:00Z"
    }
  }

  delivery_info = {
    storage_account_id = azurerm_storage_account.example.id
    container          = "cost-exports"
    root_folder_path   = "weekly"
  }

  definition = {
    type      = "ActualCost"
    timeframe = "MonthToDate"
    data_set = {
      granularity = "Daily"
      configuration = {
        columns      = []
        data_version = "2023-05-01"
      }
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azapi | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| export_name | Name of the cost export | `string` | n/a | yes |
| parent_id | Parent ID for the cost export scope | `string` | n/a | yes |
| delivery_info | Delivery destination configuration | `object` | n/a | yes |
| export_description | Description of the cost export | `string` | `"Azure Cost Export"` | no |
| format | Export format: Csv or Parquet | `string` | `"Csv"` | no |
| compression_mode | Compression mode: None, GZip | `string` | `"None"` | no |
| data_overwrite_behavior | CreateNewReport or OverwritePreviousReport | `string` | `"CreateNewReport"` | no |
| partition_data | Whether to partition the exported data | `bool` | `true` | no |
| schedule | Schedule configuration (status, recurrence, recurrence_period) | `object` | See below | no |
| definition | Export definition (type, timeframe, data_set) | `object` | See below | no |

### `schedule` object

```hcl
{
  status     = "Active"        # Active or Inactive
  recurrence = "Daily"         # Daily, Weekly, Monthly, or Annually
  recurrence_period = {
    from = "2024-10-01T00:00:00Z"
    to   = "2050-02-01T00:00:00Z"
  }
}
```

### `delivery_info` object

```hcl
{
  storage_account_id = "..."   # Resource ID of the storage account
  container          = "..."   # Blob container name
  root_folder_path   = "..."   # Folder path within the container
}
```

### `definition` object

```hcl
{
  type      = "ActualCost"     # ActualCost, AmortizedCost, or Usage
  timeframe = "MonthToDate"    # MonthToDate, WeekToDate, Custom, etc.
  data_set = {
    granularity = "Daily"      # Daily or Monthly
    configuration = {
      columns      = []        # List of columns to include (empty = all)
      data_version = "2023-05-01"
    }
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the cost export |
| name | The name of the cost export |
| identity | The identity of the cost export (including principal_id for RBAC assignments) |
| output | The full output of the cost export resource |

## Export Types

The module supports three export types via `definition.type`:

- **ActualCost**: Actual costs incurred, including on-demand usage and reservations at the prices you paid
- **AmortizedCost**: Costs with reservation purchases amortized over the reservation term
- **Usage**: Raw usage data without cost information

## Parent ID Formats

The `parent_id` variable accepts different scope formats:

- **Billing Account**: `/providers/Microsoft.Billing/billingAccounts/{billingAccountId}`
- **Billing Profile**: `/providers/Microsoft.Billing/billingAccounts/{billingAccountId}/billingProfiles/{billingProfileId}`
- **Invoice Section**: `/providers/Microsoft.Billing/billingAccounts/{billingAccountId}/billingProfiles/{billingProfileId}/invoiceSections/{invoiceSectionId}`
- **Subscription**: `/subscriptions/{subscriptionId}`
- **Resource Group**: `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}`
- **Management Group**: `/providers/Microsoft.Management/managementGroups/{managementGroupId}`

## Notes

- The module creates a cost export with a system-assigned managed identity
- The managed identity will need appropriate permissions to write to the storage account
- Data version `2023-05-01` is recommended for the latest schema
- For billing-scoped exports, ensure you have the correct billing account, profile, and invoice section IDs

## License

This module is maintained by Mozilla RelOps.
