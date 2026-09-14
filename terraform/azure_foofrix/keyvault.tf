resource "azurerm_user_assigned_identity" "worker" {
  name                = "id-foofrix-worker"
  resource_group_name = azurerm_resource_group.foofrix.name
  location            = local.location
  tags                = local.common_tags

  depends_on = [azurerm_resource_provider_registration.this["Microsoft.ManagedIdentity"]]
}

resource "azurerm_key_vault" "foofrix" {
  name                       = "kv-foofrix-${substr(azurerm_subscription.foofrix.subscription_id, 0, 8)}"
  resource_group_name        = azurerm_resource_group.foofrix.name
  location                   = local.location
  tenant_id                  = local.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  purge_protection_enabled   = true
  tags                       = local.common_tags

  depends_on = [azurerm_resource_provider_registration.this["Microsoft.KeyVault"]]
}

resource "azurerm_role_assignment" "relops_key_vault_administrator" {
  scope                = azurerm_key_vault.foofrix.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azuread_group.relops.object_id
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "foofrix_secrets_officer" {
  scope                            = azurerm_key_vault.foofrix.id
  role_definition_name             = "Key Vault Secrets Officer"
  principal_id                     = data.azuread_service_principal.foofrix.object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "worker_secrets_user" {
  scope                            = azurerm_key_vault.foofrix.id
  role_definition_name             = "Key Vault Secrets User"
  principal_id                     = azurerm_user_assigned_identity.worker.principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
