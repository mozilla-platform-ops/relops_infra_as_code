resource "azuread_application" "fuzzing_azure_devtest" {
  display_name = "sp-fuzzing-azure-devtest"
  owners       = data.azuread_group.relops.members
  notes        = "Service principal for the Fuzzing Azure DevTest Subscription. RELOPS-2440."

  web {
    redirect_uris = []

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_service_principal" "fuzzing_azure_devtest" {
  client_id                    = azuread_application.fuzzing_azure_devtest.client_id
  app_role_assignment_required = false
  owners                       = data.azuread_group.relops.members
  tags                         = concat(["name:sp-fuzzing-azure-devtest"], local.sp_tags)
}
