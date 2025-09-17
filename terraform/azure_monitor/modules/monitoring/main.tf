#############################################
# Log Analytics Workspace
#############################################

resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.name}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.law_sku
  retention_in_days   = var.law_retention_days
  tags                = var.tags
}

#############################################
# Data Collection Rule (AMA) – minimal (Perf only)
#############################################

resource "azurerm_monitor_data_collection_rule" "this" {
  name                = "${var.name}-dcr"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Windows"

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
      name                  = "law"
    }
  }

  # Perf-only data flow to minimize payload and avoid InvalidPayload
  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = ["law"]
  }

  data_sources {
    performance_counter {
      name                          = "basic-perf"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = var.perf_sample_seconds
      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Memory\\% Committed Bytes In Use"
      ]
    }
  }

  tags = var.tags
}

#############################################
# Action Group (optional for alerts)
#############################################

resource "azurerm_monitor_action_group" "this" {
  count               = var.create_action_group ? 1 : 0
  name                = "${var.name}-ag"
  resource_group_name = var.resource_group_name
  short_name          = substr("${var.name}-ag", 0, 12)

  dynamic "email_receiver" {
    for_each = var.alert_emails
    content {
      name          = replace(email_receiver.value, "@", "_")
      email_address = email_receiver.value
    }
  }

  tags = var.tags
}

locals {
  action_group_id = var.create_action_group ? azurerm_monitor_action_group.this[0].id : var.action_group_id
}

#############################################
# Metric Alert: CPU high (VM-scoped)
#############################################

resource "azurerm_monitor_metric_alert" "cpu_high" {
  count               = var.enable_alerts ? 1 : 0
  name                = "${var.name}-cpu-high"
  resource_group_name = var.resource_group_name
  scopes              = var.session_host_vm_ids
  severity            = 2
  description         = "High CPU on AVD session hosts"
  frequency           = "PT1M"
  window_size         = "PT5M"
  auto_mitigate       = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_high_threshold
  }

  dynamic "action" {
    for_each = local.action_group_id != null ? [1] : []
    content {
      action_group_id = local.action_group_id
    }
  }

  tags = var.tags
}

#############################################
# LA Query Alert: sessions near cap (workspace-scoped)
# Provider expects 'metric_measure_column' (not 'measure_column')
#############################################

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "sessions_near_cap" {
  count                   = var.enable_alerts ? 1 : 0
  name                    = "${var.name}-sessions-near-cap"
  resource_group_name     = var.resource_group_name
  location                = var.location
  severity                = 2
  evaluation_frequency    = "PT5M"
  window_duration         = "PT5M"
  enabled                 = true
  auto_mitigation_enabled = true

  scopes = [azurerm_log_analytics_workspace.this.id]

  criteria {
    query                   = <<KQL
Perf
| where ObjectName == "Terminal Services Session" and CounterName == "Active Sessions"
| summarize RecentAvg=avg(CounterValue) by Computer
| project Computer, RecentAvg
KQL
    time_aggregation_method = "Average"
    operator                = "GreaterThan"
    threshold               = 0
    metric_measure_column   = "RecentAvg"

    dimension {
      name     = "Computer"
      operator = "Include"
      values   = ["*"]
    }
  }

  dynamic "action" {
    for_each = local.action_group_id != null ? [1] : []
    content {
      action_groups = [local.action_group_id]
    }
  }

  tags = var.tags
}
