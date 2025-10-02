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
