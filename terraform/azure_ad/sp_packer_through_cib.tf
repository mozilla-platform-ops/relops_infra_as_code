data "azuread_user" "mcornmesser" {
  user_principal_name = "mcornmesser@mozilla.com"
}

# application: Packer_Through_CIB
resource "azuread_application" "Packer_Through_CIB" {
  display_name = "Packer_Through_CIB"
  # Packer bits live in the CloudImageBuilder repo
  owners = [data.azuread_user.mcornmesser.id]
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
    homepage_url = "https://github.com/mozilla-platform-ops/cloud-image-builder"
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
      admin_consent_description  = "Allow the application to access Packer_Through_CIB on behalf of the signed-in user."
      admin_consent_display_name = "Access Packer_Through_CIB"
      enabled                    = true
      id                         = "46ebc1f1-6740-4a19-ba74-0c604dfe1fd9"
      type                       = "User"
      user_consent_description   = "Allow the application to access Packer_Through_CIB on your behalf."
      user_consent_display_name  = "Access Packer_Through_CIB"
      value                      = "user_impersonation"
    }
  }
}
# service principal: Packer_Through_CIB
resource "azuread_service_principal" "Packer_Through_CIB" {
  client_id = azuread_application.Packer_Through_CIB.client_id
  tags      = concat(["name:Packer_Through_CIB"], local.sp_tags)
  owners = [
    "4e48c4fe-303d-4d1d-bd6f-76f39f7b1c08"
  ]
}
# role definition: Packer_Through_CIB
resource "azurerm_role_definition" "Packer_Through_CIB" {
  name        = "Packer_Through_CIB"
  description = "custom role supporting automated build of machine images by Packer_Through_CIB"
  scope       = data.azurerm_subscription.currentSubscription.id
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

      # delete
      "Microsoft.Compute/disks/delete",
      "Microsoft.Compute/virtualMachines/delete",
      "Microsoft.Network/networkInterfaces/delete",
      "Microsoft.Network/publicIPAddresses/delete",

      # do
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
# role assignment: Packer_Through_CIB, Packer_Through_CIB (custom role), within subscription scope
resource "azurerm_role_assignment" "Packer_Through_CIB_subscription_Packer_Through_CIB" {
  role_definition_name = azurerm_role_definition.Packer_Through_CIB.name
  principal_id         = azuread_service_principal.Packer_Through_CIB.object_id
  scope                = data.azurerm_subscription.currentSubscription.id
}
# role assignment: Packer_Through_CIB, contributor (built in role), within subscription scope
resource "azurerm_role_assignment" "Packer_Through_CIB_subscription_contributor" {
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.Packer_Through_CIB.object_id
  scope                = data.azurerm_subscription.currentSubscription.id
}