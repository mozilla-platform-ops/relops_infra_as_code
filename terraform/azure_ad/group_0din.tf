iresource "azuread_group" "odin" {
  display_name     = "0DIN"
  security_enabled = true
  mail_enabled     = false
  description      = "Terraform-managed group for subscription contributor access"
}

# Look up each user in the variable
data "azuread_user" "odin_members" {
  for_each            = toset(var.odin_group)
  user_principal_name = each.value
}

# Add each user to the group
resource "azuread_group_member" "odin_membership" {
  for_each        = data.azuread_user.odin_members
  group_object_id = azuread_group.odin.id
  member_object_id = each.value.object_id
}

# Assign Contributor role at a specific subscription
data "azurerm_subscription" "target" {
  subscription_id = "0a420ff9-bc77-4475-befc-a05071fc92ec" # adjust as needed
}

resource "azurerm_role_assignment" "odin_contributor" {
  scope                = data.azurerm_subscription.target.id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.odin.object_id
}
