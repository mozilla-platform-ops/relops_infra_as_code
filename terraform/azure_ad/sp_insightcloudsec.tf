resource "azuread_application" "insightcloudsec" {
  display_name = "sp-infosec-insightcloudsec"
  homepage     = "https://www.rapid7.com/products/insightcloudsec/"
  owners       = [data.azuread_user.jmoss.id]
}

resource "azuread_service_principal" "insightcloudsec" {
  application_id               = azuread_application.insightcloudsec.application_id
  app_role_assignment_required = false
}

resource "azurerm_role_assignment" "insightcloudsec" {
  for_each             = toset(var.insightcloudsec_scope)
  scope                = each.value
  role_definition_name = "reader"
  principal_id         = azuread_service_principal.insightcloudsec.object_id
}
