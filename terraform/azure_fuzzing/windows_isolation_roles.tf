locals {
  agent_read_delete_actions = [
    "Microsoft.Resources/subscriptions/resourceGroups/read",
    "Microsoft.Resources/subscriptions/resourceGroups/resources/read",
    "Microsoft.Compute/virtualMachines/read",
    "Microsoft.Compute/virtualMachines/delete",
    "Microsoft.Compute/disks/read",
    "Microsoft.Compute/disks/delete",
    "Microsoft.Network/networkInterfaces/read",
    "Microsoft.Network/networkInterfaces/delete",
    "Microsoft.Network/networkSecurityGroups/read",
    "Microsoft.Network/networkSecurityGroups/delete",
  ]
  windows_isolation_roles = {
    agent_controller = {
      name       = "Fuzzing Windows agent controller"
      scope      = azurerm_resource_group.windows_agents.id
      assignment = azurerm_resource_group.windows_agents.id
      principal  = data.azurerm_user_assigned_identity.run.principal_id
      actions = concat(local.agent_read_delete_actions, [
        "Microsoft.Compute/virtualMachines/write",
        "Microsoft.Compute/virtualMachines/runCommand/action",
        "Microsoft.Compute/disks/write",
        "Microsoft.Network/networkInterfaces/write",
        "Microsoft.Network/networkInterfaces/join/action",
        "Microsoft.Network/networkSecurityGroups/write",
        "Microsoft.Network/networkSecurityGroups/join/action",
      ])
      data_actions = []
    }
    agent_janitor = {
      name         = "Fuzzing Windows agent janitor"
      scope        = azurerm_resource_group.windows_agents.id
      assignment   = azurerm_resource_group.windows_agents.id
      principal    = data.azuread_service_principal.azure_janitor.object_id
      actions      = local.agent_read_delete_actions
      data_actions = []
    }
    harness_retirement = {
      name       = "Fuzzing Batch harness retirement"
      scope      = data.azurerm_resource_group.clauditor.id
      assignment = azurerm_batch_account.fuzzing_southcentralus.id
      principal  = data.azurerm_user_assigned_identity.run.principal_id
      actions = [
        "Microsoft.Batch/batchAccounts/pools/read",
        "Microsoft.Batch/batchAccounts/pools/write",
      ]
      data_actions = []
    }
    harness_janitor = {
      name       = "Fuzzing Batch harness janitor"
      scope      = data.azurerm_resource_group.clauditor.id
      assignment = azurerm_batch_account.fuzzing_southcentralus.id
      principal  = data.azuread_service_principal.azure_janitor.object_id
      actions = [
        "Microsoft.Batch/batchAccounts/pools/read",
        "Microsoft.Batch/batchAccounts/pools/write",
        "Microsoft.Batch/batchAccounts/pools/delete",
      ]
      data_actions = [
        "Microsoft.Batch/batchAccounts/jobs/read",
        "Microsoft.Batch/batchAccounts/jobs/write",
      ]
    }
    subnet_join = {
      name       = "Fuzzing agent subnet join"
      scope      = data.azurerm_resource_group.clauditor.id
      assignment = azurerm_subnet.windows_agents.id
      principal  = data.azurerm_user_assigned_identity.run.principal_id
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/read",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
      data_actions = []
    }
  }
}

resource "azurerm_role_definition" "windows_isolation" {
  for_each           = local.windows_isolation_roles
  name               = each.value.name
  scope              = each.value.scope
  assignable_scopes  = [each.value.scope]
  role_definition_id = uuidv5("url", "${each.value.scope}/${each.value.name}")

  permissions {
    actions      = each.value.actions
    data_actions = each.value.data_actions
  }
}

resource "azurerm_role_assignment" "windows_isolation" {
  for_each                         = local.windows_isolation_roles
  scope                            = each.value.assignment
  role_definition_id               = azurerm_role_definition.windows_isolation[each.key].role_definition_resource_id
  principal_id                     = each.value.principal
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
