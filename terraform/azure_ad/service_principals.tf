locals {
  # The service principal resource only accept a list of strings as tags
  # So we here we iterate over the map object, join the key and values
  # then cast it to a list
  sp_tags = [for k, v in local.common_tags : join(":", [k, v])]
}

# a reference to the current subscription
data "azurerm_subscription" "currentSubscription" {
}

# application: cloud-image-builder
resource "azuread_application" "cloud_image_builder" {
  display_name = "cloud-image-builder"
  homepage = "https://github.com/mozilla-platform-ops/cloud-image-builder"
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
}
# service principal: cloud-image-builder
resource "azuread_service_principal" "cloud_image_builder" {
  application_id = azuread_application.cloud_image_builder.application_id
  tags = concat(["name:cloud-image-builder"], local.sp_tags)
}
# role definition: cloud-image-builder
resource "azurerm_role_definition" "cloud_image_builder" {
  name                 = "cloud-image-builder"
  description          = "custom role supporting automated build of machine images by cloud-image-builder"
  scope                = data.azurerm_subscription.currentSubscription.id
  permissions {
    actions = [

      # read
      "Microsoft.Compute/*/read",
      "Microsoft.Network/*/read",
      "Microsoft.Storage/*/read",
      "Microsoft.Authorization/*/read",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/subscriptions/resourceGroups/resources/read",

      # write
      "Microsoft.Compute/disks/write",
      "Microsoft.Network/networkInterfaces/write",
      "Microsoft.Network/publicIPAddresses/write",

      # do
      "Microsoft.Compute/disks/beginGetAccess/action",
      "Microsoft.Compute/disks/endGetAccess/action",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Network/networkSecurityGroups/join/action",

    ]
  }
}
# role assignment: cloud-image-builder, cloud-image-builder (custom role), within subscription scope
resource "azurerm_role_assignment" "cloud_image_builder_subscription_cloud_image_builder" {
  role_definition_name = azurerm_role_definition.cloud_image_builder.name
  principal_id = azuread_service_principal.cloud_image_builder.object_id
  scope = data.azurerm_subscription.currentSubscription.id
}
# role assignment: cloud-image-builder, contributor (built in role), within subscription scope
resource "azurerm_role_assignment" "cloud_image_builder_subscription_contributor" {
  role_definition_name = "Contributor"
  principal_id = azuread_service_principal.cloud_image_builder.object_id
  scope = data.azurerm_subscription.currentSubscription.id
}

resource "azuread_application" "Packer_Through_CIB" {
  display_name = "Packer_Through_CIB"
}
resource "azuread_service_principal" "Packer_Through_CIB" {
  application_id = azuread_application.Packer_Through_CIB.application_id

  tags = concat(["name:Packer_Through_CIB"], local.sp_tags)
}

resource "azuread_application" "taskcluster-worker-manager-production" {
  display_name = "taskcluster-worker-manager-production"
}
resource "azuread_service_principal" "taskcluster-worker-manager-production" {
  application_id = azuread_application.taskcluster-worker-manager-production.application_id

  tags = concat(["name:taskcluster-worker-manager-production"], local.sp_tags)
}

resource "azuread_application" "taskcluster-worker-manager-staging" {
  display_name = "taskcluster-worker-manager-staging"
}
resource "azuread_service_principal" "taskcluster-worker-manager-staging" {
  application_id = azuread_application.taskcluster-worker-manager-staging.application_id

  tags = concat(["name:taskcluster-worker-manager-staging"], local.sp_tags)
}
