# CrowdStrike Falcon Next-Gen SIEM log ingestion via Azure Event Hubs.
# Subscription enumeration is driven off the tenant root management group so
# new subscriptions onboard automatically on the next apply.
#
# The Entra ID application that consumes these hubs, and its client secret,
# are managed out-of-band (client secret is created in the Azure portal and
# handed to SecOps directly - see RELOPS-2331).

data "azurerm_management_group" "tenant_root" {
  name = local.mozilla_tenant_id
}

data "azurerm_subscription" "tenant_subscriptions" {
  for_each        = toset(data.azurerm_management_group.tenant_root.subscription_ids)
  subscription_id = each.value
}

locals {
  crowdstrike_excluded_subscription_display_names = [
    "Azure subscription 1",
  ]

  crowdstrike_forwarding_subscriptions = {
    for s in data.azurerm_subscription.tenant_subscriptions :
    s.subscription_id => s.id
    if !contains(local.crowdstrike_excluded_subscription_display_names, s.display_name)
  }

  crowdstrike_common_tags = {
    terraform       = "true"
    project_name    = "azure_infrasec"
    owner_email     = "infrastructuresecurity@mozilla.com"
    source_repo_url = "https://github.com/mozilla-platform-ops/relops_infra_as_code"
  }
}

resource "azurerm_resource_group" "crowdstrikeeventhub" {
  name     = "rg-crowdstrike-eventhub"
  location = "East US 2"
  tags     = local.crowdstrike_common_tags
}

resource "azurerm_eventhub_namespace" "crowdstrike" {
  capacity                 = 4
  name                     = "mozcrowdstrikeeventhub"
  location                 = azurerm_resource_group.crowdstrikeeventhub.location
  resource_group_name      = azurerm_resource_group.crowdstrikeeventhub.name
  sku                      = "Standard"
  maximum_throughput_units = 4
  auto_inflate_enabled     = true
  minimum_tls_version      = "1.2"
  tags                     = local.crowdstrike_common_tags
}

resource "azurerm_eventhub" "crowdstrike_entralogs" {
  name                = "entralogs"
  namespace_name      = azurerm_eventhub_namespace.crowdstrike.name
  resource_group_name = azurerm_resource_group.crowdstrikeeventhub.name
  partition_count     = 4
  message_retention   = 7
}

resource "azurerm_eventhub" "crowdstrike_activitylogs" {
  name                = "activitylogs"
  namespace_name      = azurerm_eventhub_namespace.crowdstrike.name
  resource_group_name = azurerm_resource_group.crowdstrikeeventhub.name
  partition_count     = 4
  message_retention   = 7
}

# Per CrowdStrike: each NGSIEM connector requires a dedicated consumer group
# that is not shared with other applications.
resource "azurerm_eventhub_consumer_group" "crowdstrike_entralogs_ngsiem" {
  name                = "ngsiem-entra-logs"
  namespace_name      = azurerm_eventhub_namespace.crowdstrike.name
  eventhub_name       = azurerm_eventhub.crowdstrike_entralogs.name
  resource_group_name = azurerm_resource_group.crowdstrikeeventhub.name
}

resource "azurerm_eventhub_consumer_group" "crowdstrike_activitylogs_ngsiem" {
  name                = "ngsiem-activity-logs"
  namespace_name      = azurerm_eventhub_namespace.crowdstrike.name
  eventhub_name       = azurerm_eventhub.crowdstrike_activitylogs.name
  resource_group_name = azurerm_resource_group.crowdstrikeeventhub.name
}

resource "azurerm_monitor_diagnostic_setting" "crowdstrikeeventhub" {
  for_each                       = local.crowdstrike_forwarding_subscriptions
  name                           = "crowdstrike-eventhub"
  target_resource_id             = each.value
  eventhub_name                  = azurerm_eventhub.crowdstrike_activitylogs.name
  eventhub_authorization_rule_id = "/subscriptions/${local.infra_sec_subscription}/resourceGroups/${azurerm_resource_group.crowdstrikeeventhub.name}/providers/Microsoft.EventHub/namespaces/${azurerm_eventhub_namespace.crowdstrike.name}/authorizationRules/RootManageSharedAccessKey"

  enabled_log {
    category = "Administrative"
  }
  enabled_log {
    category = "Security"
  }
  enabled_log {
    category = "Alert"
  }
  enabled_log {
    category = "Policy"
  }
}

resource "azurerm_monitor_aad_diagnostic_setting" "crowdstrike" {
  name                           = "crowdstrike-eventhub"
  eventhub_name                  = azurerm_eventhub.crowdstrike_entralogs.name
  eventhub_authorization_rule_id = "/subscriptions/${local.infra_sec_subscription}/resourceGroups/${azurerm_resource_group.crowdstrikeeventhub.name}/providers/Microsoft.EventHub/namespaces/${azurerm_eventhub_namespace.crowdstrike.name}/authorizationRules/RootManageSharedAccessKey"

  enabled_log { category = "SignInLogs" }
  enabled_log { category = "AuditLogs" }
  enabled_log { category = "NonInteractiveUserSignInLogs" }
  enabled_log { category = "ServicePrincipalSignInLogs" }
  enabled_log { category = "ManagedIdentitySignInLogs" }
  enabled_log { category = "ProvisioningLogs" }
  enabled_log { category = "ADFSSignInLogs" }
  enabled_log { category = "RiskyUsers" }
  enabled_log { category = "UserRiskEvents" }
  enabled_log { category = "NetworkAccessTrafficLogs" }
  enabled_log { category = "ServicePrincipalRiskEvents" }
  enabled_log { category = "EnrichedOffice365AuditLogs" }
  enabled_log { category = "MicrosoftGraphActivityLogs" }
  enabled_log { category = "RemoteNetworkHealthLogs" }
  enabled_log { category = "RiskyServicePrincipals" }
}

output "crowdstrike_eventhub_namespace" {
  description = "Event Hub Namespace name for the Falcon NGSIEM data connector."
  value       = azurerm_eventhub_namespace.crowdstrike.name
}

output "crowdstrike_eventhub_activity_logs" {
  description = "Event Hub name carrying subscription activity logs."
  value       = azurerm_eventhub.crowdstrike_activitylogs.name
}

output "crowdstrike_eventhub_entra_logs" {
  description = "Event Hub name carrying Entra ID tenant logs."
  value       = azurerm_eventhub.crowdstrike_entralogs.name
}

output "crowdstrike_forwarding_subscriptions" {
  description = "Subscriptions currently forwarding activity logs to CrowdStrike."
  value       = keys(local.crowdstrike_forwarding_subscriptions)
}
