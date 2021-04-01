# a reference to the current subscription
data "azurerm_subscription" "currentSubscription" {}

# application: cloud-image-builder
resource "azuread_application" "cloud_image_builder" {
  display_name = "cloud-image-builder"
  homepage = "https://github.com/mozilla-platform-ops/cloud-image-builder"
  required_resource_access {
    # azure management service api
    resource_app_id = "797f4846-ba00-4fd7-ba43-dac1f8f63013"
    resource_access {
      id   = data.azurerm_subscription.currentSubscription.id
      type = "Scope"
    }
  }
  required_resource_access {
    # azure storage
    resource_app_id = "e406a681-f3d4-42a8-90b6-c2b029497af1"
    resource_access {
      id   = data.azurerm_subscription.currentSubscription.id
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
      "Microsoft.Compute/diskAccesses/delete",
      "Microsoft.Compute/diskAccesses/privateEndpointConnectionProxies/delete",
      "Microsoft.Compute/diskAccesses/privateEndpointConnections/delete",
      "Microsoft.Compute/disks/delete",
      "Microsoft.Compute/virtualMachines/delete",
      "Microsoft.Network/networkInterfaces/delete",
      "Microsoft.Network/publicIPAddresses/delete",

      # action
      "Microsoft.Compute/diskAccesses/privateEndpointConnectionProxies/validate/action",
      "Microsoft.Compute/diskAccesses/privateEndpointConnectionsApproval/action",
      "Microsoft.Compute/disks/beginGetAccess/action",
      "Microsoft.Compute/disks/endGetAccess/action",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Network/networkSecurityGroups/join/action",
      "Microsoft.Network/publicIPAddresses/join/action",
      "Microsoft.Network/virtualNetworks/subnets/join/action",
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