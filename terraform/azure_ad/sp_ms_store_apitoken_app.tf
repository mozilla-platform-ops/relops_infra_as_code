resource "azuread_application" "ms_store_apitoken_app" {
  display_name = "MS Store API Token app"
  owners       = [data.azuread_user.mcornmesser.object_id]
  api {
    known_client_applications      = []
    mapped_claims_enabled          = false
    requested_access_token_version = 1

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access MS Store API Token app on behalf of the signed-in user."
      admin_consent_display_name = "Access MS Store API Token app"
      enabled                    = true
      id                         = "6fe7ec7c-35d3-4144-8a7f-7e68f9f08c84"
      type                       = "User"
      user_consent_description   = "Allow the application to access MS Store API Token app on your behalf."
      user_consent_display_name  = "Access MS Store API Token app"
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

resource "azuread_service_principal" "ms_store_apitoken_app" {
  client_id = azuread_application.ms_store_apitoken_app.client_id
  tags      = concat(["name:ms_store_apitoken_app"], local.sp_tags)
}
