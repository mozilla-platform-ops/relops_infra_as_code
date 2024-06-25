resource "azuread_application" "splunkeventhub" {
  display_name = "sp-infosec-splunkeventhub"
  owners       = [data.azuread_user.jmoss.id]
}

resource "azuread_service_principal" "splunkeventhub" {
  application_id               = azuread_application.splunkeventhub.application_id
  app_role_assignment_required = false
}
