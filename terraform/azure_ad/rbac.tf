data "azuread_group" "infrasec" {
  display_name     = "Infrastructure Security Team"
  security_enabled = true
}

data "azuread_group" "releng" {
  display_name     = "Releng"
  security_enabled = true
}

# Assign Billing Reader role to the specified group across all subscriptions
resource "azurerm_role_assignment" "billing_reader_releng" {
  for_each             = toset(var.azure_subscriptions)
  scope                = each.value
  role_definition_name = "Billing Reader"
  principal_id         = data.azuread_group.releng.object_id
}

## contributor to non-ci sub
resource "azurerm_role_assignment" "releng_contributor" {
  for_each = toset([
    "/subscriptions/0a420ff9-bc77-4475-befc-a05071fc92ec",
  ])
  scope                = each.value
  role_definition_name = "Contributor"
  principal_id         = data.azuread_group.releng.object_id
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
  principal_id         = data.azuread_group.releng.object_id
}

resource "azurerm_role_assignment" "infrasec_reader" {
  for_each             = toset(var.azure_subscriptions)
  scope                = each.value
  role_definition_name = "reader"
  principal_id         = data.azuread_group.infrasec.object_id
}

resource "azurerm_role_assignment" "splunkeventhub" {
  for_each             = toset(var.azure_subscriptions)
  scope                = each.value
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azuread_service_principal.splunkeventhub.object_id
}

variable "azure_subscriptions" {
  type        = list(any)
  description = "List of subscriptions to be assigned to infrastructure team"
  default     = []
}
