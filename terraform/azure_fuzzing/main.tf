locals {
  tenant_id = "c0dc8bb0-b616-427e-8217-9513964a145b"

  fuzzing_subscription_id = "d6e6a496-6005-4e31-b2f5-209440c2cf52"

  subscription_alias = "fuzzing-azure-devtest-subscription"
  subscription_name  = "Fuzzing Azure DevTest Subscription"

  billing_account_id         = "05ef9068-c74c-54a9-5b8f-82f7fb8b32cd:6e104178-9e3c-470c-9787-8ef53f372665_2019-05-31"
  mozilla_billing_profile_id = "GRUW-TLBL-BG7-PGB"
  mozilla_invoice_section_id = "VVEC-AWWS-PJA-PGB"

  billing_scope_id = "/providers/Microsoft.Billing/billingAccounts/${local.billing_account_id}/billingProfiles/${local.mozilla_billing_profile_id}/invoiceSections/${local.mozilla_invoice_section_id}"

  common_tags = {
    terraform        = "true"
    project_name     = "azure_fuzzing"
    production_state = "production"
    owner_email      = "relops@mozilla.com"
    source_repo_url  = "https://github.com/mozilla-platform-ops/relops_infra_as_code"
  }

  resource_provider_registrations = toset([
    "Microsoft.Batch",
    "Microsoft.Compute",
    "Microsoft.Quota",
  ])
}

data "azuread_service_principal" "fuzzing_azure_devtest" {
  display_name = "sp-fuzzing-azure-devtest"
}

data "azuread_group" "relops" {
  display_name = "Relops"
}

resource "azurerm_subscription" "fuzzing" {
  alias             = local.subscription_alias
  subscription_name = local.subscription_name
  billing_scope_id  = local.billing_scope_id
  workload          = "DevTest"
  tags              = local.common_tags

  timeouts {
    create = "60m"
  }
}

resource "azurerm_role_assignment" "fuzzing_service_principal_contributor" {
  scope                            = "/subscriptions/${azurerm_subscription.fuzzing.subscription_id}"
  role_definition_name             = "Contributor"
  principal_id                     = data.azuread_service_principal.fuzzing_azure_devtest.object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "relops_owner" {
  scope                = "/subscriptions/${azurerm_subscription.fuzzing.subscription_id}"
  role_definition_name = "Owner"
  principal_id         = data.azuread_group.relops.object_id
  principal_type       = "Group"
}

resource "azurerm_resource_provider_registration" "this" {
  for_each = local.resource_provider_registrations
  name     = each.value

  depends_on = [azurerm_subscription.fuzzing]
}
