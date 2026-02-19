# Azure AD security group for 0DIN
resource "azuread_group" "zero_din" {
  display_name     = "0DIN"
  security_enabled = true
  mail_enabled     = false
  description      = "Terraform-managed Azure AD group for 0DIN members"
}

# Resolve users listed in zero_din_group
data "azuread_user" "zero_din_members" {
  for_each            = toset(var.zero_din_group)
  user_principal_name = each.value
}

# Add members to the 0DIN group
resource "azuread_group_member" "zero_din_membership" {
  for_each         = data.azuread_user.zero_din_members
  group_object_id  = azuread_group.zero_din.object_id
  member_object_id = each.value.object_id
}
