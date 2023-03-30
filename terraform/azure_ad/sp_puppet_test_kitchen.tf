resource "azuread_application" "puppet_test_kitchen" {
  display_name = "Puppet-Test-Kitchen"
  owners       = [data.azuread_user.mcornmesser.id]
}

resource "azuread_service_principal" "puppet_test_kitchen" {
  application_id = azuread_application.puppet_test_kitchen.application_id
  tags           = concat(["name:Puppet-Test-Kitchen"], local.sp_tags)
}

resource "azurerm_role_assignment" "puppet_test_kitchen_contributor" {
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.puppet_test_kitchen.object_id
  scope                = data.azurerm_subscription.currentSubscription.id
}

