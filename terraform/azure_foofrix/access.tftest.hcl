mock_provider "azurerm" {
  mock_resource "azurerm_key_vault" {
    defaults = {
      id = "/subscriptions/11111111-2222-3333-4444-555555555555/resourceGroups/rg-foofrix/providers/Microsoft.KeyVault/vaults/kv-foofrix-test"
    }
  }
}
mock_provider "azurerm" {
  alias = "billing"
}
mock_provider "azuread" {}

override_resource {
  target = azurerm_subscription.foofrix
  values = {
    subscription_id = "11111111-2222-3333-4444-555555555555"
  }
}

run "access_boundaries" {
  # All providers are mocked; this does not create cloud resources.
  command = apply

  assert {
    condition = (
      azurerm_role_assignment.foofrix_contributor.scope == "/subscriptions/11111111-2222-3333-4444-555555555555" &&
      azurerm_role_assignment.foofrix_contributor.role_definition_name == "Contributor"
    )
    error_message = "The GCP provisioner must have Contributor access only in FooFrix."
  }

  assert {
    condition = (
      azurerm_role_assignment.worker_secrets_user.scope == azurerm_key_vault.foofrix.id &&
      azurerm_role_assignment.worker_secrets_user.role_definition_name == "Key Vault Secrets User"
    )
    error_message = "The worker must have read access at the FooFrix vault scope."
  }

  assert {
    condition = (
      azurerm_role_assignment.relops_owner.scope == "/subscriptions/11111111-2222-3333-4444-555555555555" &&
      azurerm_role_assignment.relops_owner.role_definition_name == "Owner"
    )
    error_message = "RelOps must retain ownership of the new subscription."
  }
}
