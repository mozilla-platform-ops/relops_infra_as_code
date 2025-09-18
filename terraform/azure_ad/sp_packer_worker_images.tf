data "azuread_user" "jmoss" {
  user_principal_name = "jmoss@mozilla.com"
}

# application: worker_images_dev
resource "azuread_application" "worker_images_dev" {
  display_name = "worker_images_dev"
  owners       = [data.azuread_user.jmoss.id]
  web {
    homepage_url = "https://github.com/mozilla-platform-ops/worker-images"
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
      admin_consent_description  = "Allow the application to access worker_images_dev on behalf of the signed-in user."
      admin_consent_display_name = "Access worker_images_dev"
      enabled                    = true
      id                         = "eed6d0f7-2a3d-4ec0-9cf1-450561e39baa"
      type                       = "User"
      user_consent_description   = "Allow the application to access worker_images_dev on your behalf."
      user_consent_display_name  = "Access worker_images_dev"
      value                      = "user_impersonation"
    }
  }
}

resource "azuread_service_principal" "worker_images_dev" {
  client_id = azuread_application.worker_images_dev.client_id
}

resource "azurerm_role_assignment" "worker_images_dev" {
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.worker_images_dev.object_id
  scope                = "/subscriptions/0a420ff9-bc77-4475-befc-a05071fc92ec"
}

resource "azuread_application" "worker_images_fxci" {
  display_name = "worker_images_fxci"
  owners       = [data.azuread_user.jmoss.id]
  web {
    homepage_url = "https://github.com/mozilla-platform-ops/worker-images"
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
      admin_consent_description  = "Allow the application to access worker_images_fxci on behalf of the signed-in user."
      admin_consent_display_name = "Access worker_images_fxci"
      enabled                    = true
      id                         = "3713cebd-288c-4e92-8094-f1eaeda6068b"
      type                       = "User"
      user_consent_description   = "Allow the application to access worker_images_fxci on your behalf."
      user_consent_display_name  = "Access worker_images_fxci"
      value                      = "user_impersonation"
    }
  }
}

resource "azuread_service_principal" "worker_images_fxci" {
  client_id = azuread_application.worker_images_fxci.client_id
}

resource "azurerm_role_assignment" "worker_images_fxci" {
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.worker_images_fxci.object_id
  scope                = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"
}

resource "azuread_application" "worker_images_fxci_trusted" {
  display_name = "worker_images_fxci_trusted"
  owners       = [data.azuread_user.jmoss.id]
  web {
    homepage_url = "https://github.com/mozilla-platform-ops/worker-images"
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
      admin_consent_description  = "Allow the application to access worker_images_fxci_trusted on behalf of the signed-in user."
      admin_consent_display_name = "Access worker_images_fxci_trusted"
      enabled                    = true
      id                         = "6c3df0e0-a624-493e-b5d9-fdc8dd0a23ed"
      type                       = "User"
      user_consent_description   = "Allow the application to access worker_images_fxci_trusted on your behalf."
      user_consent_display_name  = "Access worker_images_fxci_trusted"
      value                      = "user_impersonation"
    }
  }
}

resource "azuread_service_principal" "worker_images_fxci_trusted" {
  client_id = azuread_application.worker_images_fxci_trusted.client_id
}

resource "azurerm_role_assignment" "worker_images_fxci_trusted" {
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.worker_images_fxci_trusted.object_id
  scope                = "/subscriptions/a30e97ab-734a-4f3b-a0e4-c51c0bff0701"
}

# application: worker_manager_tceng
resource "azuread_application" "worker_images_tceng" {
  display_name = "worker_images_tceng"
  owners       = [data.azuread_user.mcornmesser.id]
  api {
    known_client_applications      = []
    mapped_claims_enabled          = false
    requested_access_token_version = 1

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access worker_manager_tceng on behalf of the signed-in user."
      admin_consent_display_name = "Access worker_manager_tceng"
      enabled                    = true
      id                         = "6fba0d54-b477-4351-bdbf-6ecdfa7b27aa"
      type                       = "User"
      user_consent_description   = "Allow the application to access worker_manager_tceng on your behalf."
      user_consent_display_name  = "Access worker_manager_tceng"
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

resource "azuread_service_principal" "worker_images_tceng" {
  client_id = azuread_application.worker_images_tceng.client_id
}

resource "azurerm_role_assignment" "worker_images_tceng" {
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.worker_images_tceng.object_id
  scope                = "/subscriptions/8a205152-b25a-417f-a676-80465535a6c9"
}

# application: worker_manager_monitor
# A stable GUID for the scope (created once, re-used forever)
resource "random_uuid" "worker_images_monitor_scope" {}

resource "azuread_application" "worker_images_monitor" {
  display_name = "worker_images_monitor"
  owners       = [data.azuread_user.mcornmesser.id]

  api {
    requested_access_token_version = 1

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access worker_manager_monitor on behalf of the signed-in user."
      admin_consent_display_name = "Access worker_manager_monitor"
      enabled                    = true
      id                         = random_uuid.worker_images_monitor_scope.result
      type                       = "User"
      user_consent_description   = "Allow the application to access worker_manager_monitor on your behalf."
      user_consent_display_name  = "Access worker_manager_monitor"
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

resource "azuread_service_principal" "worker_images_monitor" {
  client_id = azuread_application.worker_images_monitor.client_id
}

resource "azurerm_role_assignment" "worker_images_monitor" {
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.worker_images_monitor.object_id
  scope                = "/subscriptions/36c94cc5-8e6d-49db-a034-bb82b6a2632e"
}
