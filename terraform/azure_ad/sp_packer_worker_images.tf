data "azuread_user" "jmoss" {
  user_principal_name = "jmoss@mozilla.com"
}

# application: worker_images_dev
resource "azuread_application" "worker_images_dev" {
  display_name = "worker_images_dev"
  homepage     = "https://github.com/mozilla-platform-ops/worker-images"
  owners       = [data.azuread_user.jmoss.id]
}

resource "azuread_service_principal" "worker_images_dev" {
  application_id = azuread_application.worker_images_dev.application_id
}

resource "azurerm_role_assignment" "worker_images_dev" {
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.worker_images_dev.object_id
  scope                = "/subscriptions/0a420ff9-bc77-4475-befc-a05071fc92ec"
}

resource "azuread_application" "worker_images_fxci" {
  display_name = "worker_images_fxci"
  homepage     = "https://github.com/mozilla-platform-ops/worker-images"
  owners       = [data.azuread_user.jmoss.id]
}

resource "azuread_service_principal" "worker_images_fxci" {
  application_id = azuread_application.worker_images_fxci.application_id
}

resource "azurerm_role_assignment" "worker_images_fxci" {
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.worker_images_fxci.object_id
  scope                = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"
}

resource "azuread_application" "worker_images_fxci_trusted" {
  display_name = "worker_images_fxci_trusted"
  homepage     = "https://github.com/mozilla-platform-ops/worker-images"
  owners       = [data.azuread_user.jmoss.id]
}

resource "azuread_service_principal" "worker_images_fxci_trusted" {
  application_id = azuread_application.worker_images_fxci_trusted.application_id
}

resource "azurerm_role_assignment" "worker_images_fxci_trusted" {
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.worker_images_fxci_trusted.object_id
  scope                = "/subscriptions/a30e97ab-734a-4f3b-a0e4-c51c0bff0701"
}
