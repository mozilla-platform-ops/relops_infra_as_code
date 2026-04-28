# Assign Billing Reader role to the specified group across all subscriptions
resource "azurerm_role_assignment" "billing_reader_releng" {
  for_each             = toset(var.azure_subscriptions)
  scope                = each.value
  role_definition_name = "Billing Reader"
  principal_id         = azuread_group.releng.object_id
}

## contributor to non-ci sub
resource "azurerm_role_assignment" "releng_contributor" {
  for_each = toset([
    "/subscriptions/0a420ff9-bc77-4475-befc-a05071fc92ec",
  ])
  scope                = each.value
  role_definition_name = "Contributor"
  principal_id         = azuread_group.releng.object_id
}

## reader to the others
resource "azurerm_role_assignment" "releng_reader" {
  for_each = toset([
    "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0",
    "/subscriptions/8a205152-b25a-417f-a676-80465535a6c9",
    "/subscriptions/a30e97ab-734a-4f3b-a0e4-c51c0bff0701",
    "/subscriptions/e1cb04e4-3788-471a-881f-385e66ad80ab",
    "/subscriptions/9b9774fb-67f1-45b7-830f-aafe07a94396"
  ])
  scope                = each.value
  role_definition_name = "reader"
  principal_id         = azuread_group.releng.object_id
}

resource "azurerm_role_assignment" "tceng_reader" {
  for_each = toset([
    "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"
  ])
  scope                = each.value
  role_definition_name = "reader"
  principal_id         = azuread_group.tceng.object_id
}

resource "azurerm_role_assignment" "infrasec_reader" {
  for_each             = toset(var.azure_subscriptions)
  scope                = each.value
  role_definition_name = "reader"
  principal_id         = azuread_group.infrasec.object_id
}

# Reader on the tenant root management group so operators running terraform in
# azure_infrasec can resolve the "azurerm_management_group.tenant_root" data
# source (used to enumerate subscriptions for CrowdStrike log forwarding).
resource "azurerm_role_assignment" "infrasec_tenant_root_mg_reader" {
  scope                = "/providers/Microsoft.Management/managementGroups/c0dc8bb0-b616-427e-8217-9513964a145b"
  role_definition_name = "Reader"
  principal_id         = azuread_group.infrasec.object_id
}

resource "azurerm_role_assignment" "releng_tenant_root_mg_reader" {
  scope                = "/providers/Microsoft.Management/managementGroups/c0dc8bb0-b616-427e-8217-9513964a145b"
  role_definition_name = "Reader"
  principal_id         = azuread_group.releng.object_id
}

resource "azurerm_role_assignment" "splunkeventhub" {
  for_each             = toset(var.azure_subscriptions)
  scope                = each.value
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azuread_service_principal.splunkeventhub.object_id
}

# Scoped to the CrowdStrike Event Hub Namespace only (least-privilege per the
# Falcon NGSIEM connector guide). The namespace is managed in the
# azure_infrasec workspace; this references it by constructed resource ID.
resource "azurerm_role_assignment" "crowdstrikeeventhub" {
  scope                = "/subscriptions/${var.infra_sec_subscription_id}/resourceGroups/rg-crowdstrike-eventhub/providers/Microsoft.EventHub/namespaces/mozcrowdstrikeeventhub"
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azuread_service_principal.crowdstrikeeventhub.object_id
}

variable "azure_subscriptions" {
  type        = list(any)
  description = "List of subscriptions to be assigned to infrastructure team"
  default     = []
}

# Look up the 0DIN subscription
data "azurerm_subscription" "zero_din" {
  subscription_id = var.zero_din_subscription_id
}

# Assign Contributor role to the 0DIN group at the subscription scope
resource "azurerm_role_assignment" "zero_din_contributor" {
  scope                = data.azurerm_subscription.zero_din.id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.zero_din.object_id
}

# Relops — Contributor on FXCI, Trusted FXCI, 0DIN, and FF Non-CI
resource "azurerm_role_assignment" "relops_contributor" {
  for_each = toset([
    "/subscriptions/${var.fxci_devtest_subscription_id}",
    "/subscriptions/${var.trusted_fxci_subscription_id}",
    "/subscriptions/${var.zero_din_subscription_id}",
    "/subscriptions/${var.firefox_nonci_subscription_id}",
  ])
  scope                = each.value
  role_definition_name = "Contributor"
  principal_id         = azuread_group.relops.object_id
}

# CI Billing — Billing Administrator directory role (tenant-wide)
data "azuread_directory_role" "billing_admin" {
  display_name = "Billing Administrator"
}

resource "azuread_directory_role_member" "ci_billing_billing_admin" {
  role_object_id   = data.azuread_directory_role.billing_admin.object_id
  member_object_id = azuread_group.ci_billing.object_id
}

# CI Billing — Cost Management Contributor on FXCI, Trusted FXCI, and FF Non-CI
resource "azurerm_role_assignment" "ci_billing_cost_mgmt_contributor" {
  for_each = toset([
    "/subscriptions/${var.fxci_devtest_subscription_id}",
    "/subscriptions/${var.trusted_fxci_subscription_id}",
    "/subscriptions/${var.firefox_nonci_subscription_id}",
  ])
  scope                = each.value
  role_definition_name = "Cost Management Contributor"
  principal_id         = azuread_group.ci_billing.object_id
}

# Firefox Enterprise VMs — Contributor on FF Non-CI
resource "azurerm_role_assignment" "firefox_enterprise_vms_contributor" {
  scope                = "/subscriptions/${var.firefox_nonci_subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_group.firefox_enterprise_vms.object_id
}

# Relops — additional roles from ticket audit
resource "azurerm_role_assignment" "relops_billing_reader" {
  for_each = toset([
    "/subscriptions/${var.fxci_devtest_subscription_id}",
    "/subscriptions/${var.firefox_nonci_subscription_id}",
  ])
  scope                = each.value
  role_definition_name = "Billing Reader"
  principal_id         = azuread_group.relops.object_id
}

resource "azurerm_role_assignment" "relops_security_reader" {
  for_each = toset([
    "/subscriptions/${var.fxci_devtest_subscription_id}",
    "/subscriptions/${var.firefox_nonci_subscription_id}",
  ])
  scope                = each.value
  role_definition_name = "Security Reader"
  principal_id         = azuread_group.relops.object_id
}

resource "azurerm_role_assignment" "relops_user_access_admin" {
  for_each = toset([
    "/subscriptions/${var.fxci_devtest_subscription_id}",
    "/subscriptions/${var.firefox_nonci_subscription_id}",
  ])
  scope                = each.value
  role_definition_name = "User Access Administrator"
  principal_id         = azuread_group.relops.object_id
}

resource "azurerm_role_assignment" "relops_eventhubs_data_sender" {
  scope                = "/subscriptions/${var.firefox_nonci_subscription_id}"
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = azuread_group.relops.object_id
}

# Taskcluster — Contributor on TCEng
resource "azurerm_role_assignment" "tceng_contributor" {
  scope                = "/subscriptions/${var.taskcluster_subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_group.tceng.object_id
}

# Security Engineering — Monitoring Reader on FXCI; Security Reader on FXCI and Trusted FXCI
resource "azurerm_role_assignment" "security_engineering_monitoring_reader" {
  scope                = "/subscriptions/${var.fxci_devtest_subscription_id}"
  role_definition_name = "Monitoring Reader"
  principal_id         = azuread_group.security_engineering.object_id
}

resource "azurerm_role_assignment" "security_engineering_security_reader" {
  for_each = toset([
    "/subscriptions/${var.fxci_devtest_subscription_id}",
    "/subscriptions/${var.trusted_fxci_subscription_id}",
  ])
  scope                = each.value
  role_definition_name = "Security Reader"
  principal_id         = azuread_group.security_engineering.object_id
}

# Cognitive Services — Contributor, Cognitive Services Contributor, and Custom Vision Contributor on FF Non-CI
resource "azurerm_role_assignment" "cognitive_services_roles" {
  for_each = toset([
    "Contributor",
    "Cognitive Services Contributor",
    "Cognitive Services Custom Vision Contributor",
  ])
  scope                = "/subscriptions/${var.firefox_nonci_subscription_id}"
  role_definition_name = each.value
  principal_id         = azuread_group.cognitive_services.object_id
}

# Data SRE — Contributor on FF Non-CI
resource "azurerm_role_assignment" "data_sre_contributor" {
  scope                = "/subscriptions/${var.firefox_nonci_subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_group.data_sre.object_id
}

# SEIO — Contributor on FXCI main CI subscription
resource "azurerm_role_assignment" "seio_contributor" {
  scope                = "/subscriptions/${var.fxci_devtest_subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_group.seio.object_id
}
