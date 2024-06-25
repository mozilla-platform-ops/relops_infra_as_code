variable "azure_subscriptions" {
  type        = list(any)
  description = "List of subscriptions to be used with insightcloudsec"
  default     = []
}

resource "azurerm_resource_group" "splunkeventhub" {
  name     = "rg-splunk-eventhub"
  location = "East US 2"
  tags = merge(local.common_tags,
    tomap({
      "tag_owner_email" = "infrastructuresecurity@mozilla.com"
    })
  )
}

resource "azurerm_eventhub_namespace" "splunk" {
  name                     = "mozsplunkeventhub"
  location                 = azurerm_resource_group.splunkeventhub.location
  resource_group_name      = azurerm_resource_group.splunkeventhub.name
  sku                      = "Standard"
  maximum_throughput_units = 4
  auto_inflate_enabled     = true

  tags = merge(local.common_tags,
    tomap({
      "tag_owner_email" = "infrastructuresecurity@mozilla.com"
    })
  )
}

resource "azurerm_eventhub" "entralogs" {
  name                = "entralogs"
  namespace_name      = azurerm_eventhub_namespace.splunk.name
  resource_group_name = azurerm_resource_group.splunkeventhub.name
  partition_count     = 2
  message_retention   = 7
}

resource "azurerm_eventhub" "activitylogs" {
  name                = "activitylogs"
  namespace_name      = azurerm_eventhub_namespace.splunk.name
  resource_group_name = azurerm_resource_group.splunkeventhub.name
  partition_count     = 2
  message_retention   = 7
}

resource "azurerm_monitor_diagnostic_setting" "splunkeventhub" {
  for_each                       = toset(var.azure_subscriptions)
  name                           = "splunk-eventhub"
  target_resource_id             = each.value
  eventhub_name                  = azurerm_eventhub.activitylogs.name
  eventhub_authorization_rule_id = "${data.azurerm_subscription.currentSubscription.id}/resourceGroups/${azurerm_resource_group.splunkeventhub.name}/providers/Microsoft.EventHub/namespaces/${azurerm_eventhub_namespace.splunk.name}/authorizationRules/RootManageSharedAccessKey"

  log {
    category = "Administrative"
    enabled  = true
  }

  log {
    category = "Security"
    enabled  = true
  }

  log {
    category = "Alert"
    enabled  = true
  }

  log {
    category = "Policy"
    enabled  = true
  }
}

resource "azurerm_monitor_aad_diagnostic_setting" "splunk" {
  name                           = "splunk-eventhub"
  eventhub_name                  = azurerm_eventhub.entralogs.name
  eventhub_authorization_rule_id = "${data.azurerm_subscription.currentSubscription.id}/resourceGroups/${azurerm_resource_group.splunkeventhub.name}/providers/Microsoft.EventHub/namespaces/${azurerm_eventhub_namespace.splunk.name}/authorizationRules/RootManageSharedAccessKey"

  enabled_log {
    category = "SignInLogs"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "AuditLogs"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "NonInteractiveUserSignInLogs"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "ServicePrincipalSignInLogs"
    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "ManagedIdentitySignInLogs"
    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "ProvisioningLogs"
    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "ADFSSignInLogs"
    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "RiskyUsers"
    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "UserRiskEvents"
    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "NetworkAccessTrafficLogs"
    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "ServicePrincipalRiskEvents"
    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "EnrichedOffice365AuditLogs"
    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "MicrosoftGraphActivityLogs"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "RemoteNetworkHealthLogs"
    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "RiskyServicePrincipals"
    retention_policy {
      enabled = false
    }
  }
}
