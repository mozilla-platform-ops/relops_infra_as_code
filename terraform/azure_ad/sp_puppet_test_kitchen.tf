resource "azuread_application" "puppet_test_kitchen" {
  display_name = "Puppet-Test-Kitchen"
  owners       = [data.azuread_user.mcornmesser.id]
  api {
    known_client_applications      = []
    mapped_claims_enabled          = false
    requested_access_token_version = 1

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access Puppet-Test-Kitchen on behalf of the signed-in user."
      admin_consent_display_name = "Access Puppet-Test-Kitchen"
      enabled                    = true
      id                         = "bc09b9e2-ca7c-4109-9644-c620b6a6599b"
      type                       = "User"
      user_consent_description   = "Allow the application to access Puppet-Test-Kitchen on your behalf."
      user_consent_display_name  = "Access Puppet-Test-Kitchen"
      value                      = "user_impersonation"
    }
  }

  web {
    redirect_uris = []

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_service_principal" "puppet_test_kitchen" {
  client_id = azuread_application.puppet_test_kitchen.client_id
  tags      = concat(["name:Puppet-Test-Kitchen"], local.sp_tags)
  owners = [
    "4e48c4fe-303d-4d1d-bd6f-76f39f7b1c08"
  ]
}

resource "azurerm_role_assignment" "puppet_test_kitchen_contributor" {
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.puppet_test_kitchen.object_id
  scope                = data.azurerm_subscription.currentSubscription.id
}