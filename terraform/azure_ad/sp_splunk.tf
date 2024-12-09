resource "azuread_application" "splunkeventhub" {
  display_name = "sp-infosec-splunkeventhub"
  owners       = [data.azuread_user.jmoss.id]
  web {
    redirect_uris = []

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
  api {
    known_client_applications      = []
    mapped_claims_enabled          = false
    requested_access_token_version = 1

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access sp-infosec-splunkeventhub on behalf of the signed-in user."
      admin_consent_display_name = "Access sp-infosec-splunkeventhub"
      enabled                    = true
      id                         = "c9fd5b23-0534-4627-a9c0-85a5ae79bccf"
      type                       = "User"
      user_consent_description   = "Allow the application to access sp-infosec-splunkeventhub on your behalf."
      user_consent_display_name  = "Access sp-infosec-splunkeventhub"
      value                      = "user_impersonation"
    }
  }
}

resource "azuread_service_principal" "splunkeventhub" {
  client_id                    = azuread_application.splunkeventhub.client_id
  app_role_assignment_required = false
}
