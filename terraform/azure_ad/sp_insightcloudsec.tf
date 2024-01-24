variable "insightcloudsec_scope" {
  type = list(any)
  description = "List of subscriptions to be used with insightcloudsec"
  default = []
}

resource "azuread_application" "insightcloudsec" {
  display_name = "sp-infosec-insightcloudsec"
  homepage     = "https://www.rapid7.com/products/insightcloudsec/"
  owners       = [data.azuread_user.jmoss.id]
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    resource_access {
      id   = "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30"
      type = "Role"
    }
    resource_access {
      id   = "b0afded3-3588-46d8-8b3d-9842eff778da"
      type = "Role"
    }
    resource_access {
      id   = "5b567255-7703-4780-807c-7be8301ae99b"
      type = "Role"
    }
    resource_access {
      id   = "246dd0d5-5bd0-4def-940b-0421030a5b68"
      type = "Role"
    }
    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214"
      type = "Role"
    }
  }
}

resource "azuread_service_principal" "insightcloudsec" {
  application_id               = azuread_application.insightcloudsec.application_id
  app_role_assignment_required = false
}

resource "azurerm_role_assignment" "insightcloudsec" {
  for_each             = toset(var.insightcloudsec_scope)
  scope                = each.value
  role_definition_name = "reader"
  principal_id         = azuread_service_principal.insightcloudsec.object_id
}
