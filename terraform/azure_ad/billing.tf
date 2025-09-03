# Assign Billing Reader role to the specified group across all subscriptions
resource "azurerm_role_assignment" "billing_reader_releng" {
  for_each             = toset(var.azure_subscriptions)
  scope                = each.value
  role_definition_name = "Billing Reader"
  principal_id         = "848f45ae-56a8-45ef-bb46-3f937de8efd1" ## Releng
}