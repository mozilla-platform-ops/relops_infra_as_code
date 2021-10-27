resource "azurerm_resource_group" "rg-central-us-runbooks" {
  name     = "rg-central-us-runbooks"
  location = "Central US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-central-us-runbooks"
    })
  )
}

# azurerm_automation_account will be created here
# but will need a run as account or managed identy to work.
resource "azurerm_automation_account" "resource-monitor" {
  name                = "resource-monitor"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.rg-central-us-runbooks.name
  sku_name            = "Basic"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "resource-monitor"
    })
  )
}
resource "azurerm_automation_module" "az-accounts" {
  name                    = "Az.Accounts"
  resource_group_name     = azurerm_automation_account.resource-monitor.resource_group_name
  automation_account_name = azurerm_automation_account.resource-monitor.name
  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Az.Accounts/2.5.2"
  }
}
resource "azurerm_automation_module" "az-resources" {
  name                    = "Az.Resources"
  resource_group_name     = azurerm_automation_account.resource-monitor.resource_group_name
  automation_account_name = azurerm_automation_account.resource-monitor.name
  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Az.Resources"
  }
}
resource "azurerm_automation_schedule" "once-a-week" {
  name                    = "once-a-week"
  resource_group_name     = azurerm_automation_account.resource-monitor.resource_group_name
  automation_account_name = azurerm_automation_account.resource-monitor.name
  frequency               = "Week"
  interval                = 1
  description             = "Once a week schedule"
  week_days               = ["Wednesday"]
}
resource "azurerm_automation_schedule" "once-a-day" {
  name                    = "once-a-day"
  resource_group_name     = azurerm_automation_account.resource-monitor.resource_group_name
  automation_account_name = azurerm_automation_account.resource-monitor.name
  frequency               = "Day"
  description             = "Once a day schedule"
}
resource "azurerm_automation_schedule" "every-4-hours" {
  name                    = "every-4-hours"
  resource_group_name     = azurerm_automation_account.resource-monitor.resource_group_name
  automation_account_name = azurerm_automation_account.resource-monitor.name
  frequency               = "Hour"
  interval                = 4
  description             = "Every 4 hours"
}
resource "azurerm_automation_schedule" "every-2-hours" {
    name                    = "every-2-hours"
    resource_group_name     = azurerm_automation_account.resource-monitor.resource_group_name
    automation_account_name = azurerm_automation_account.resource-monitor.name
    frequency               = "Hour"
    interval                = 2
    description             = "Every 2 hours"
}
resource "azurerm_automation_schedule" "every-hour" {
  name                    = "every-hour"
  resource_group_name     = azurerm_automation_account.resource-monitor.resource_group_name
  automation_account_name = azurerm_automation_account.resource-monitor.name
  frequency               = "Hour"
  interval                = 1
  description             = "Every hour"
}
resource "azurerm_automation_schedule" "once" {
  name                    = "once"
  resource_group_name     = azurerm_automation_account.resource-monitor.resource_group_name
  automation_account_name = azurerm_automation_account.resource-monitor.name
  frequency               = "OneTime"
}

data "local_file" "tmp_rg_cleanup_ps1" {
  filename = "runbooks/tmp_rg_cleanup.ps1"
}
resource "azurerm_automation_runbook" "tmp_rg_cleanup" {
  name                    = "tmp_rg_cleanup"
  location                = azurerm_automation_account.resource-monitor.location
  resource_group_name     = azurerm_automation_account.resource-monitor.resource_group_name
  automation_account_name = azurerm_automation_account.resource-monitor.name
  log_verbose             = "false"
  log_progress            = "true"
  description             = "Clean up missed temp resource groups"
  runbook_type            = "PowerShell"
  content                 = data.local_file.tmp_rg_cleanup_ps1.content
  tags = merge(local.common_tags,
    tomap({
      "Name" = "tmp_rg_cleanup"
    })
  )
}
resource "azurerm_automation_job_schedule" "tmp_rg_cleanup" {
  resource_group_name     = azurerm_automation_account.resource-monitor.resource_group_name
  automation_account_name = azurerm_automation_account.resource-monitor.name
  schedule_name           = azurerm_automation_schedule.every-4-hours.name
  runbook_name            = azurerm_automation_runbook.tmp_rg_cleanup.name
}

data "local_file" "vm_day_audit_ps1" {
  filename = "runbooks/vm_day_audit.ps1"
}
resource "azurerm_automation_runbook" "vm_day_audit" {
  name                    = "vm_day_audit"
  location                = azurerm_automation_account.resource-monitor.location
  resource_group_name     = azurerm_automation_account.resource-monitor.resource_group_name
  automation_account_name = azurerm_automation_account.resource-monitor.name
  log_verbose             = "false"
  log_progress            = "true"
  description             = "Audit VMs' uptime and agent status"
  runbook_type            = "PowerShell"
  content                 = data.local_file.vm_day_audit_ps1.content
  tags = merge(local.common_tags,
    tomap({
      "Name" = "tmp_rg_cleanup"
    })
  )
}
resource "azurerm_automation_job_schedule" "vm_day_audit" {
  resource_group_name     = azurerm_automation_account.resource-monitor.resource_group_name
  automation_account_name = azurerm_automation_account.resource-monitor.name
  schedule_name           = azurerm_automation_schedule.once-a-day.name
  runbook_name            = azurerm_automation_runbook.vm_day_audit.name
}

data "local_file" "worker_scanner_helper_ps1" {
  filename = "runbooks/worker_scanner_helper.ps1"
}
resource "azurerm_automation_runbook" "worker_scanner_helper" {
  name                    = "worker_scanner_helper"
  location                = azurerm_automation_account.resource-monitor.location
  resource_group_name     = azurerm_automation_account.resource-monitor.resource_group_name
  automation_account_name = azurerm_automation_account.resource-monitor.name
  log_verbose             = "false"
  log_progress            = "true"
  description             = "Delete unassociated old resources"
  runbook_type            = "PowerShell"
  content                 = data.local_file.worker_scanner_helper_ps1.content
  tags = merge(local.common_tags,
    tomap({
      "Name" = "tmp_rg_cleanup"
    })
  )
}
resource "azurerm_automation_job_schedule" "worker_scanner_helper" {
  resource_group_name     = azurerm_automation_account.resource-monitor.resource_group_name
  automation_account_name = azurerm_automation_account.resource-monitor.name
  schedule_name           = azurerm_automation_schedule.every-2-hours.name
  runbook_name            = azurerm_automation_runbook.worker_scanner_helper.name
}
