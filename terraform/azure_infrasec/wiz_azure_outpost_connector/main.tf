locals {
  # If service_principal_object_id is provided, use it directly
  # Otherwise, use the lookup or creation logic
  azure_ad_sp = var.wiz_app_object_id != "" ? var.wiz_app_object_id : (
    var.use_existing_service_principal ? data.azuread_service_principal.wiz_for_azure[0].object_id : azuread_service_principal.wiz_for_azure[0].object_id
  )
}

resource "azuread_service_principal" "wiz_for_azure" {
  count     = var.use_existing_service_principal ? 0 : 1
  client_id = var.wiz_app_id
}

data "azuread_service_principal" "wiz_for_azure" {
  # Only perform lookup if we're using existing SP and object_id is not directly provided
  count     = var.use_existing_service_principal && var.wiz_app_object_id == "" ? 1 : 0
  client_id = var.wiz_app_id
}

data "azuread_application_published_app_ids" "well_known" {}

resource "azuread_service_principal" "msgraph" {
  # If entra_id_scanning is true, create the Wiz for Azure service principal
  count        = local.entra_id_scanning ? 1 : 0
  client_id    = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing = true
}

locals {
  application_roles = ["Directory.Read.All", "Policy.Read.All", "RoleManagement.Read.All", "AccessReview.Read.All", "AuditLog.Read.All"]
}

resource "azuread_app_role_assignment" "sp_grant_role_consent" {
  # If entra_id_scanning is true, grant the Wiz for Azure service principal the required permissions to read the Microsoft Graph
  count               = local.entra_id_scanning && !var.use_existing_service_principal ? length(local.application_roles) : 0
  app_role_id         = azuread_service_principal.msgraph[0].app_role_ids[local.application_roles[count.index]]
  principal_object_id = local.azure_ad_sp
  resource_object_id  = azuread_service_principal.msgraph[0].object_id

  depends_on = [
    azuread_service_principal.msgraph
  ]
}

# IAM
# Create Wiz Custom Role

locals {
  management_group_id = "/providers/Microsoft.Management/managementGroups/${var.azure_management_group_id}"
  subscription_id     = "/subscriptions/${var.azure_subscription_id}"

  scope        = try(coalesce(var.azure_management_group_id != "" ? local.management_group_id : null, var.azure_subscription_id != "" ? local.subscription_id : null), "")
  scope_exists = length(local.scope) > 0

  entra_id_scanning = var.enable_entra_id_scanning

  WIZ_CUSTOM_ROLE_ACTIONS = [
    "Microsoft.Compute/snapshots/read",
    "Microsoft.ContainerRegistry/registries/webhooks/getCallbackConfig/action",
    "Microsoft.ContainerRegistry/registries/webhooks/listEvents/action",
    "Microsoft.DataFactory/factories/querydataflowdebugsessions/action",
    "Microsoft.HDInsight/clusters/read",
    "Microsoft.Web/sites/config/list/Action",
    "Microsoft.Web/sites/slots/config/list/Action"
]

}

# Create Wiz Custom Role for Wiz for Azure app
resource "azurerm_role_definition" "wiz_custom_role" {
  name  = var.wiz_custom_role_name
  scope = local.scope
  count = local.scope_exists ? 1 : 0

  description = "Wiz Custom Role"

  permissions {
    actions = concat(
      local.WIZ_CUSTOM_ROLE_ACTIONS
    )
  }

  assignable_scopes = [local.scope]
}

# Create the Wiz custom roles with a time delay to allow the Azure dataplane to catch up. You can leave the max default variable to the default.
# The creation of Azure custom role can take several minutes and needs to be completed before the role assignments are made, or the role assignments will simply not happen.
# Similarly, you may notice that deletion of the custom role can take several minutes to complete when you run `terraform destroy`.
resource "time_sleep" "wait_for_azure_dataplane_custom_role" {
  depends_on      = [azurerm_role_definition.wiz_custom_role]
  count           = local.scope_exists ? 1 : 0
  create_duration = var.azure_wait_timer
}

# Assign Custom Roles to Wiz for Azure App
resource "azurerm_role_assignment" "wiz_custom_role_assignment" {
  scope                = local.scope
  count                = local.scope_exists ? 1 : 0
  principal_id         = local.azure_ad_sp
  role_definition_name = var.wiz_custom_role_name
  depends_on           = [time_sleep.wait_for_azure_dataplane_custom_role]
}

# Assign Wiz for Azure app to built-in roles
resource "azurerm_role_assignment" "wiz_k8s_cluster_role_assignment" {
  scope                = local.scope
  count                = local.scope_exists ? 1 : 0
  principal_id         = local.azure_ad_sp
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
}

resource "azurerm_role_assignment" "wiz_k8s_rbac_role_assignment" {
  scope                = local.scope
  count                = local.scope_exists ? 1 : 0
  principal_id         = local.azure_ad_sp
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
}

resource "azurerm_role_assignment" "wiz_reader_role_assignment" {
  scope                = local.scope
  count                = local.scope_exists ? 1 : 0
  principal_id         = local.azure_ad_sp
  role_definition_name = "Reader"
}

resource "azurerm_role_assignment" "wiz_openai_role_assignment" {
  scope                = local.scope
  count                = local.scope_exists && var.enable_openai_scanning ? 1 : 0
  principal_id         = local.azure_ad_sp
  role_definition_name = "Cognitive Services OpenAI User"
}
