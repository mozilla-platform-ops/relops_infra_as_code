data "azuread_client_config" "current" {}

data "azuread_user" "jwatkins" {
  user_principal_name = "jwatkins@mozilla.com"
}

resource "azuread_application" "mr2_app" {
  display_name = "Pro Client"
  owners       = [data.azuread_user.jwatkins.id]

  # The sign_in_audience must be set in the manifest after the app is created.
  # When azuread v2.x is released, it should support "AzureADandPersonalMicrosoftAccount"
  # sign_in_audience = "AzureADandPersonalMicrosoftAccount"
  # https://github.com/hashicorp/terraform-provider-azuread/issues/175
  # https://docs.microsoft.com/en-us/azure/active-directory/develop/supported-accounts-validation

  # logo must be added to the app post creating via UI
  # https://github.com/hashicorp/terraform-provider-azuread/issues/418

  # Currently Web is the only platform application able to be configured
  # This needs to be set in the UI
  # Authentication -> Add platform -> 'Mobile and desktop application' -> 'https://localhost/oauth'
  # https://github.com/hashicorp/terraform-provider-azuread/issues/501

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    # Microsoft Graph.User.Read Delegated
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
    # Microsoft Graph.Calender.Read Delegated
    resource_access {
      id   = "465a38f9-76ea-45b9-9f34-9e8b0d4b0b42"
      type = "Scope"
    }
    # Microsoft Graph.Mail.Read Delegated
    resource_access {
      id   = "570282fd-fa5c-430d-a7fd-fc8dc98a9dca"
      type = "Scope"
    }
  }
}
