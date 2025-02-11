# application: taskcluster-worker-manager-production
resource "azuread_application" "taskcluster-worker-manager-production" {
  display_name = "taskcluster-worker-manager-production"
  required_resource_access {
    # azure management service api
    resource_app_id = "797f4846-ba00-4fd7-ba43-dac1f8f63013"
    resource_access {
      id   = "41094075-9dad-400e-a0bd-54e686782033"
      type = "Scope"

    }
  }
  required_resource_access {
    # azure storage
    resource_app_id = "e406a681-f3d4-42a8-90b6-c2b029497af1"
    resource_access {
      id   = "03e0da56-190b-40ad-a80c-ea378c433f7f"
      type = "Scope"
    }
  }
  web {
    homepage_url = "https://firefox-ci-tc.services.mozilla.com/"
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
  api {
    known_client_applications      = []
    mapped_claims_enabled          = false
    requested_access_token_version = 1

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access taskcluster-worker-manager-production on behalf of the signed-in user."
      admin_consent_display_name = "Access taskcluster-worker-manager-production"
      enabled                    = true
      id                         = "c18c93e8-8d9c-4efe-b2d0-df6a2a1e57b6"
      type                       = "User"
      user_consent_description   = "Allow the application to access taskcluster-worker-manager-production on your behalf."
      user_consent_display_name  = "Access taskcluster-worker-manager-production"
      value                      = "user_impersonation"
    }
  }
}
# service principal: taskcluster-worker-manager-production
resource "azuread_service_principal" "taskcluster-worker-manager-production" {
  client_id = azuread_application.taskcluster-worker-manager-production.client_id
  tags      = concat(["name:taskcluster-worker-manager-production"], local.sp_tags)
}
# application: taskcluster-worker-manager-stagging
resource "azuread_application" "taskcluster-worker-manager-staging" {
  display_name = "taskcluster-worker-manager-staging"
  required_resource_access {
    # azure management service api
    resource_app_id = "797f4846-ba00-4fd7-ba43-dac1f8f63013"
    resource_access {
      id   = "41094075-9dad-400e-a0bd-54e686782033"
      type = "Scope"

    }
  }
  required_resource_access {
    # azure storage
    resource_app_id = "e406a681-f3d4-42a8-90b6-c2b029497af1"
    resource_access {
      id   = "03e0da56-190b-40ad-a80c-ea378c433f7f"
      type = "Scope"
    }
  }
  web {
    homepage_url = "https://stage.taskcluster.nonprod.cloudops.mozgcp.net/"
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
  api {
    known_client_applications      = []
    mapped_claims_enabled          = false
    requested_access_token_version = 1

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access taskcluster-worker-manager-staging on behalf of the signed-in user."
      admin_consent_display_name = "Access taskcluster-worker-manager-staging"
      enabled                    = true
      id                         = "3bcc80ea-8ea0-49b4-901f-8fc3b231dabb"
      type                       = "User"
      user_consent_description   = "Allow the application to access taskcluster-worker-manager-staging on your behalf."
      user_consent_display_name  = "Access taskcluster-worker-manager-staging"
      value                      = "user_impersonation"
    }
  }
}
# service principal: taskcluster-worker-manager-production
resource "azuread_service_principal" "taskcluster-worker-manager-staging" {
  client_id = azuread_application.taskcluster-worker-manager-staging.client_id
  tags      = concat(["name:taskcluster-worker-manager-staging"], local.sp_tags)
}
# role definition: taskcluster-worker-manager-production
resource "azurerm_role_definition" "taskcluster-worker-manager" {
  name        = "taskcluster-worker-manager"
  description = "custom role supporting resource creation and deletion by Taskcluster worker-managers"
  scope       = data.azurerm_subscription.currentSubscription.id
  permissions {
    actions = [

      # read
      "Microsoft.Authorization/*/read",
      "Microsoft.Compute/*/read",
      "Microsoft.Insights/alertRules/*",
      "Microsoft.Network/*/read",
      "Microsoft.ResourceHealth/availabilityStatuses/read",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/subscriptions/resourceGroups/resources/read",
      "Microsoft.Storage/*/read",
      "Microsoft.Support/*",

      # write
      "Microsoft.Compute/diskAccesses/write",
      "Microsoft.Compute/diskAccesses/privateEndpointConnectionProxies/write",
      "Microsoft.Compute/diskAccesses/privateEndpointConnections/write",
      "Microsoft.Compute/disks/write",
      "Microsoft.Compute/virtualMachines/write",

      "Microsoft.Network/networkInterfaces/write",
      "Microsoft.Network/publicIPAddresses/write",

      # delete
      "Microsoft.Compute/disks/delete",
      "Microsoft.Compute/virtualMachines/delete",
      "Microsoft.Network/networkInterfaces/delete",
      "Microsoft.Network/publicIPAddresses/delete",
      "Microsoft.Compute/diskAccesses/delete",
      "Microsoft.Compute/diskAccesses/privateEndpointConnectionProxies/delete",
      "Microsoft.Compute/diskAccesses/privateEndpointConnections/delete",

      # do
      "Microsoft.Compute/disks/beginGetAccess/action",
      "Microsoft.Compute/disks/endGetAccess/action",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Network/networkSecurityGroups/join/action",
      "Microsoft.Network/publicIPAddresses/join/action",
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Compute/diskAccesses/privateEndpointConnectionProxies/validate/action",
      "Microsoft.Compute/diskAccesses/privateEndpointConnectionsApproval/action"
    ]
  }
}
# role assignment: taskcluster-worker-manager-production, taskcluster-worker-manager (custom role), within subscription scope
resource "azurerm_role_assignment" "taskcluster-worker-manager-production_subscription_taskcluster-worker-manager" {
  role_definition_name = azurerm_role_definition.taskcluster-worker-manager.name
  principal_id         = azuread_service_principal.taskcluster-worker-manager-production.object_id
  scope                = data.azurerm_subscription.currentSubscription.id
}
# role assignment: taskcluster-worker-manager-production, contributor (built in role), within subscription scope
resource "azurerm_role_assignment" "taskcluster-worker-manager-production_subscription_contributor" {
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.taskcluster-worker-manager-production.object_id
  scope                = data.azurerm_subscription.currentSubscription.id
}
# role assignment: taskcluster-worker-manager-staging, taskcluster-worker-manager (custom role), within subscription scope
resource "azurerm_role_assignment" "taskcluster-worker-manager-production_subscription_taskcluster-worker-staging" {
  role_definition_name = azurerm_role_definition.taskcluster-worker-manager.name
  principal_id         = azuread_service_principal.taskcluster-worker-manager-staging.object_id
  scope                = data.azurerm_subscription.currentSubscription.id
}
# role assignment: taskcluster-worker-manager-staging, contributor (built in role), within subscription scope
resource "azurerm_role_assignment" "taskcluster-worker-manager-staging_subscription_contributor" {
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.taskcluster-worker-manager-staging.object_id
  scope                = data.azurerm_subscription.currentSubscription.id
}

# application: worker_manager_tceng
resource "azuread_application" "worker_manager_tceng" {
  display_name = "worker_manager_tceng"
  owners = [
    "fdb37821-4f7e-4c00-8c7e-e5344306e6f8",
    "a1ca5b04-b1ad-4e52-9edb-2d7b30e9198c",
    "4cdab8cc-ae18-4a1f-92ad-264e67a1cc30"
  ]
  api {
    known_client_applications      = []
    mapped_claims_enabled          = false
    requested_access_token_version = 1

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access worker_manager_tceng on behalf of the signed-in user."
      admin_consent_display_name = "Access worker_manager_tceng"
      enabled                    = true
      id                         = "5ac0ddfb-49be-45a0-bec1-38926db089a4"
      type                       = "User"
      user_consent_description   = "Allow the application to access worker_manager_tceng on your behalf."
      user_consent_display_name  = "Access worker_manager_tceng"
      value                      = "user_impersonation"
    }
  }

  web {
    redirect_uris = []

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_service_principal" "worker_manager_tceng" {
  client_id = azuread_application.worker_manager_tceng.client_id
  owners = [
    "4cdab8cc-ae18-4a1f-92ad-264e67a1cc30",
    "a1ca5b04-b1ad-4e52-9edb-2d7b30e9198c",
    "fdb37821-4f7e-4c00-8c7e-e5344306e6f8",
  ]
}

resource "azurerm_role_assignment" "worker_manager_tceng" {
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.worker_manager_tceng.object_id
  scope                = "/subscriptions/8a205152-b25a-417f-a676-80465535a6c9"
}

resource "azurerm_role_assignment" "sig_workerimages" {
  role_definition_name = "reader"
  principal_id         = azuread_service_principal.worker_manager_tceng.object_id
  scope                = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/resourceGroups/rg-packer-worker-images"
}