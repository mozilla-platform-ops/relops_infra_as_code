locals {
  principals = toset(var.principal_ids)
}

# Assign the role per principal at the DAG scope
resource "azurerm_role_assignment" "dag_access" {
  for_each = local.principals

  scope                = var.app_group_id
  role_definition_name = var.role_definition_name
  principal_id         = each.value

  # If you're assigning to service principals in tenants with conditional access,
  # uncomment the next line to bypass AAD checks during creation:
  # skip_service_principal_aad_check = true
}
