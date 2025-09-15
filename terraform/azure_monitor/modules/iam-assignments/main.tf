data "azurerm_role_definition" "desktop_virtualization_user" {
  name  = "Desktop Virtualization User"
  scope = var.app_group_id
}

resource "azurerm_role_assignment" "assign" {
  for_each           = toset(var.principal_ids)
  scope              = var.app_group_id
  role_definition_id = data.azurerm_role_definition.desktop_virtualization_user.role_definition_id
  principal_id       = each.value
}
