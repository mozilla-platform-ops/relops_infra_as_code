resource "azuread_authentication_strength_policy" "authenticator_app" {
  display_name = "Authenticator app or stronger"
  description  = "Microsoft Authenticator push or a TOTP app; also accepts Authenticator passwordless, Windows Hello for Business, and FIDO2. Excludes SMS, voice, and email."

  allowed_combinations = [
    "password,microsoftAuthenticatorPush",
    "password,softwareOath",
    "deviceBasedPush",
    "windowsHelloForBusiness",
    "fido2",
  ]
}

resource "azuread_conditional_access_policy" "ms_store_partner_center" {
  display_name = "Partner Center - require authenticator app"
  state        = "enabledForReportingButNotEnforced"

  conditions {
    client_app_types = ["all"]

    applications {
      # Microsoft Partner Center; confirmed from sign-in logs in RELOPS-2513.
      included_applications = ["fabfbdc4-5751-471c-ac43-3826fa1afc31"]
    }

    users {
      included_groups = [azuread_group.ms_store_publishers.object_id]
    }
  }

  grant_controls {
    operator                          = "OR"
    authentication_strength_policy_id = azuread_authentication_strength_policy.authenticator_app.id
  }
}
