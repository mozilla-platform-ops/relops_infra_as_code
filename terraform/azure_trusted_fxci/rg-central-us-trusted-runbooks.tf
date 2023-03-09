data "azurerm_subscription" "currentSubscription" {}

resource "azurerm_resource_group" "rg-central-us-trusted-runbooks" {
  name     = "rg-central-us-trusted-runbooks"
  location = "Central US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-central-us-trusted-runbooks"
    })
  )
}

## Though user assign identity is an AD entity it is being managed here
## since it is in the runbook resource group and used by this sub
resource "azurerm_user_assigned_identity" "trusted-resource-manager" {
  name                = "trusted-resource-manager"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.rg-central-us-trusted-runbooks.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "trusted-resource-manager"
    })
  )
}
## Allow deletion but nor creation of resources
resource "azurerm_role_definition" "trusted-resource-manager" {
  name        = "trusted-resource-manager"
  description = "a custom role allowing identifying and delegation of resources"
  scope       = data.azurerm_subscription.currentSubscription.id
  permissions {
    actions = [
      # delete
      "Microsoft.Compute/disks/delete",
      "Microsoft.Compute/virtualMachines/delete",
      "Microsoft.Network/networkInterfaces/delete",
      "Microsoft.Network/publicIPAddresses/delete",
      "Microsoft.Resources/subscriptions/resourceGroups/delete",
    ]
  }
}
## Allow Read
resource "azurerm_role_assignment" "trusted-resource-manager-sub-reader" {
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.trusted-resource-manager.principal_id
  scope                = data.azurerm_subscription.currentSubscription.id
}
## Allow start/stop of VMs
resource "azurerm_role_assignment" "trusted-resource-manager-vm-contributor" {
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_user_assigned_identity.trusted-resource-manager.principal_id
  scope                = data.azurerm_subscription.currentSubscription.id
}
resource "azurerm_role_assignment" "trusted-resource-manager" {
  role_definition_name = azurerm_role_definition.trusted-resource-manager.name
  principal_id         = azurerm_user_assigned_identity.trusted-resource-manager.principal_id
  scope                = data.azurerm_subscription.currentSubscription.id
}
## Associate User Assigned identy with automation account
resource "azurerm_automation_account" "trusted-resource-manager" {
  name                = "trusted-resource-manager"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.rg-central-us-trusted-runbooks.name
  sku_name            = "Basic"
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.trusted-resource-manager.id]
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "trusted-resource-manager"
    })
  )
}

## Each automation account needs its own schedules
resource "azurerm_automation_schedule" "every-2-hours-trusted-resource-manager" {
  name                    = "every-2-hours-trusted-resource-manager"
  resource_group_name     = azurerm_automation_account.trusted-resource-manager.resource_group_name
  automation_account_name = azurerm_automation_account.trusted-resource-manager.name
  frequency               = "Hour"
  interval                = 2
  description             = "Every 2 hours"
}
resource "azurerm_automation_schedule" "every-4-hours-trusted-resource-manager" {
  name                    = "every-4-hours"
  resource_group_name     = azurerm_automation_account.trusted-resource-manager.resource_group_name
  automation_account_name = azurerm_automation_account.trusted-resource-manager.name
  frequency               = "Hour"
  interval                = 4
  description             = "Every 4 hours"
}

resource "azurerm_automation_schedule" "once-a-day-trusted-resource-manager" {
  name                    = "once-a-day"
  resource_group_name     = azurerm_automation_account.trusted-resource-manager.resource_group_name
  automation_account_name = azurerm_automation_account.trusted-resource-manager.name
  frequency               = "Day"
  description             = "Once a day schedule"
}
resource "azurerm_automation_schedule" "once-a-week-trusted-resource-manager" {
  name                    = "once-a-week"
  resource_group_name     = azurerm_automation_account.trusted-resource-manager.resource_group_name
  automation_account_name = azurerm_automation_account.trusted-resource-manager.name
  frequency               = "Week"
  interval                = 1
  description             = "Once a week schedule"
  week_days               = ["Wednesday"]
}
resource "azurerm_automation_schedule" "once-trusted-resource-manager" {
  name                    = "once"
  resource_group_name     = azurerm_automation_account.trusted-resource-manager.resource_group_name
  automation_account_name = azurerm_automation_account.trusted-resource-manager.name
  frequency               = "OneTime"
}

## Runbooks
data "local_file" "tmp_rg_cleanup_v2_ps1" {
  filename = "runbooks/tmp_rg_cleanup_v2.ps1"
}
resource "azurerm_automation_runbook" "tmp_rg_cleanup_v2" {
  name                    = "tmp_rg_cleanup_v2"
  location                = azurerm_automation_account.trusted-resource-manager.location
  resource_group_name     = azurerm_automation_account.trusted-resource-manager.resource_group_name
  automation_account_name = azurerm_automation_account.trusted-resource-manager.name
  log_verbose             = "false"
  log_progress            = "true"
  description             = "Clean up missed temp resource groups"
  runbook_type            = "PowerShell"
  content                 = data.local_file.tmp_rg_cleanup_v2_ps1.content
  tags = merge(local.common_tags,
    tomap({
      "Name" = "tmp_rg_cleanup_v2"
    })
  )
}
resource "azurerm_automation_job_schedule" "tmp_rg_cleanup_v2" {
  resource_group_name     = azurerm_automation_account.trusted-resource-manager.resource_group_name
  automation_account_name = azurerm_automation_account.trusted-resource-manager.name
  schedule_name           = azurerm_automation_schedule.once-a-week-trusted-resource-manager.name
  runbook_name            = azurerm_automation_runbook.tmp_rg_cleanup_v2.name
}
data "local_file" "vm_day_audit_v2_ps1" {
  filename = "runbooks/vm_day_audit_v2.ps1"
}
resource "azurerm_automation_runbook" "vm_day_audit_v2" {
  name                    = "vm_day_audit_v2"
  location                = azurerm_automation_account.trusted-resource-manager.location
  resource_group_name     = azurerm_automation_account.trusted-resource-manager.resource_group_name
  automation_account_name = azurerm_automation_account.trusted-resource-manager.name
  log_verbose             = "false"
  log_progress            = "true"
  description             = "Audit VMs' uptime and agent status"
  runbook_type            = "PowerShell"
  content                 = data.local_file.vm_day_audit_v2_ps1.content
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vm_day_audit_v2"
    })
  )
}
resource "azurerm_automation_job_schedule" "vm_day_audit_v2" {
  resource_group_name     = azurerm_automation_account.trusted-resource-manager.resource_group_name
  automation_account_name = azurerm_automation_account.trusted-resource-manager.name
  schedule_name           = azurerm_automation_schedule.once-a-day-trusted-resource-manager.name
  runbook_name            = azurerm_automation_runbook.vm_day_audit_v2.name
}
