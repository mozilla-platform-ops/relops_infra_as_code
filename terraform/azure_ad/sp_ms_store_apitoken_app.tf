resource "azuread_application" "ms_store_apitoken_app" {
  display_name = "MS Store API Token app"
  owners       = [data.azuread_user.mcornmesser.id]
}

resource "azuread_service_principal" "ms_store_apitoken_app" {
  application_id = azuread_application.ms_store_apitoken_app.application_id
  tags           = concat(["name:ms_store_apitoken_app"], local.sp_tags)
}
