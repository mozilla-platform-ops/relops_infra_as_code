# Contributor role assignments on the Fuzzing Azure DevTest Subscription for the
# clauditor service principals. The applications themselves are created in the
# azure_ad module; here we look them up by display name and grant access, the same
# way sp-fuzzing-azure-devtest is wired in main.tf. RELOPS-2440.

locals {
  clauditor_role = "Contributor"
  clauditor_sps = {
    build    = "sp-clauditor-build"
    audience = "sp-clauditor-audience"
    run      = "sp-clauditor-run"
  }
}

data "azuread_service_principal" "clauditor" {
  for_each     = local.clauditor_sps
  display_name = each.value
}

resource "azurerm_role_assignment" "clauditor_contributor" {
  for_each                         = data.azuread_service_principal.clauditor
  scope                            = "/subscriptions/${azurerm_subscription.fuzzing.subscription_id}"
  role_definition_name             = local.clauditor_role
  principal_id                     = each.value.object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
