resource "azapi_resource" "cost_export" {
  type      = "Microsoft.CostManagement/exports@2025-03-01"
  name      = var.export_name
  parent_id = var.parent_id
  location  = "global"

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      schedule = {
        status     = var.status
        recurrence = var.recurrence
        recurrencePeriod = {
          from = var.recurrence_period_from
          to   = var.recurrence_period_to
        }
      }
      exportDescription     = var.export_description
      format                = var.format
      compressionMode       = var.compression_mode
      dataOverwriteBehavior = var.data_overwrite_behavior
      deliveryInfo = {
        destination = {
          type           = "AzureBlob"
          resourceId     = var.storage_account_id
          container      = var.container_name
          rootFolderPath = var.root_folder_path
        }
      }
      partitionData = var.partition_data
      definition = {
        type      = var.cost_type
        timeframe = var.timeframe
        dataSet = {
          granularity = var.granularity
          configuration = {
            columns     = var.columns
            dataVersion = var.data_version
          }
        }
      }
    }
  }
}
