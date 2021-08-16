data "azuread_user" "jwatkins" {
  user_principal_name = "jwatkins@mozilla.com"
}

data "azurerm_resource_group" "puppet_test_kitchen_rg" {
  name = "Puppet-Test-Kitchen"
}
resource "azuread_application" "puppet_test_kitchen" {
  display_name = "Puppet-Test-Kitchen"
  owners       = [data.azuread_user.jwatkins.id]
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

