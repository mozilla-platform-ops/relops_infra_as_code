locals {
  tenant_id = "c0dc8bb0-b616-427e-8217-9513964a145b"
  location  = "centralus"

  billing_account_id         = "05ef9068-c74c-54a9-5b8f-82f7fb8b32cd:6e104178-9e3c-470c-9787-8ef53f372665_2019-05-31"
  mozilla_billing_profile_id = "GRUW-TLBL-BG7-PGB"
  mozilla_invoice_section_id = "VVEC-AWWS-PJA-PGB"
  billing_scope_id           = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.mozilla_billing_profile_id}/invoiceSections/${local.mozilla_invoice_section_id}"

  common_tags = {
    terraform        = "true"
    project_name     = "azure_foofrix"
    production_state = "production"
    owner_email      = "relops@mozilla.com"
    source_repo_url  = "https://github.com/mozilla-platform-ops/relops_infra_as_code"
  }
}

resource "azurerm_subscription" "foofrix" {
  provider          = azurerm.billing
  alias             = "foofrix-azure-devtest-subscription"
  subscription_name = "FooFrix Azure DevTest Subscription"
  billing_scope_id  = local.billing_scope_id
  workload          = "DevTest"
  tags              = local.common_tags

  timeouts {
    create = "60m"
  }
}

data "azuread_group" "relops" {
  display_name = "Relops"
}

data "azuread_service_principal" "foofrix" {
  display_name = "sp-foofrix-azure-devtest"
}

resource "azurerm_role_assignment" "relops_owner" {
  scope                = "/subscriptions/${azurerm_subscription.foofrix.subscription_id}"
  role_definition_name = "Owner"
  principal_id         = data.azuread_group.relops.object_id
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "foofrix_contributor" {
  scope                            = "/subscriptions/${azurerm_subscription.foofrix.subscription_id}"
  role_definition_name             = "Contributor"
  principal_id                     = data.azuread_service_principal.foofrix.object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_resource_provider_registration" "this" {
  for_each = toset([
    "Microsoft.Compute",
    "Microsoft.KeyVault",
    "Microsoft.ManagedIdentity",
    "Microsoft.Network",
    "Microsoft.Quota",
    "Microsoft.Storage",
  ])
  name = each.value
}

resource "azurerm_resource_group" "foofrix" {
  name     = "rg-foofrix"
  location = local.location
  tags     = local.common_tags
}

data "azuread_group" "platform_performance" {
  display_name     = "Platform Performance"
  security_enabled = true
}

resource "azurerm_role_assignment" "platform_performance_contributor" {
  scope                = "/subscriptions/${azurerm_subscription.foofrix.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = data.azuread_group.platform_performance.object_id
  principal_type       = "Group"
}
