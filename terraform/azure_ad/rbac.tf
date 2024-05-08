data "azuread_group" "infrasec" {
  display_name     = "Infrastructure Security Team"
  security_enabled = true
}

resource "azurerm_role_assignment" "infrasec_reader" {
  for_each             = toset(var.azure_subscriptions)
  scope                = each.value
  role_definition_name = "reader"
  principal_id         = data.azuread_group.infrasec.object_id
}

variable "azure_subscriptions" {
  type = list(any)
  description = "List of subscriptions to be assigned to infrastructure team"
  default = []
}