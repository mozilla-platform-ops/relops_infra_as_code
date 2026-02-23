data "azuread_group" "relops" {
  display_name     = "Relops"
  security_enabled = true
}

resource "azuread_application" "ronin_puppet_test_kitchen" {
  display_name = "ronin-puppet-test-kitchen"
  owners       = data.azuread_group.relops.members

  web {
    homepage_url = "https://github.com/mozilla-platform-ops/ronin_puppet"

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_service_principal" "ronin_puppet_test_kitchen" {
  client_id = azuread_application.ronin_puppet_test_kitchen.client_id
  tags      = concat(["name:ronin-puppet-test-kitchen"], local.sp_tags)
  owners    = data.azuread_group.relops.members
}

resource "azurerm_role_assignment" "ronin_puppet_test_kitchen_contributor" {
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.ronin_puppet_test_kitchen.object_id
  scope                = "/subscriptions/${var.fxci_devtest_subscription_id}"
}

resource "azuread_application_federated_identity_credential" "ronin_puppet_test_kitchen_pr" {
  application_id = azuread_application.ronin_puppet_test_kitchen.id
  display_name   = "github-actions-pr"
  description    = "GitHub Actions OIDC for pull_request workflows in mozilla-platform-ops/ronin_puppet"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:mozilla-platform-ops/ronin_puppet:pull_request"
}

resource "azuread_application_federated_identity_credential" "ronin_puppet_test_kitchen_branches" {
  application_id = azuread_application.ronin_puppet_test_kitchen.id
  display_name   = "github-actions-branches"
  description    = "GitHub Actions OIDC for branch workflows in mozilla-platform-ops/ronin_puppet"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:mozilla-platform-ops/ronin_puppet:ref:refs/heads/*"
}
