/*
=================================================
WIZ DISK ANALYZER ORCHESTRATOR APP, SP, PASSWORD
=================================================
*/

locals {
  use_orchestrator_wiz_managed_app = var.wiz_da_orchestrator_wiz_managed_app_id != "00000000-0000-0000-0000-000000000000" ? true : false
}
data "azuread_client_config" "current" {}

resource "azuread_application" "wiz_da_orchestrator" {
  count            = local.use_orchestrator_wiz_managed_app ? 0 : 1
  display_name     = var.wiz_da_orchestrator_app_name
  owners                       = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"
  api {
    requested_access_token_version = 2
  }
  web {
    homepage_url = "https://app.wiz.io"
  }

  feature_tags {
    custom_single_sign_on = false
    enterprise            = false
    gallery               = false
    hide                  = false
  }
}

resource "azuread_application_password" "wiz_da_orchestrator_pass" {
  count          = local.use_orchestrator_wiz_managed_app ? 0 : 1
  display_name   = "Wiz Disk Analyzer - Orchestrator"
  application_id = azuread_application.wiz_da_orchestrator[count.index].id
  end_date       = timeadd(formatdate("YYYY-MM-DD'T'00:00:00Z", timestamp()), var.key_expire_end_date_relative) # 24h * 365 days * 10 years
}

resource "azuread_service_principal" "wiz_da_orchestrator_sp" {
  client_id                    = local.use_orchestrator_wiz_managed_app ? var.wiz_da_orchestrator_wiz_managed_app_id : azuread_application.wiz_da_orchestrator[0].client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
  feature_tags {
    custom_single_sign_on = false
    enterprise            = false
    gallery               = false
    hide                  = false
  }
  use_existing = true
}

/*
=================================================
WIZ DISK ANALYZER SCANNER APP, SP, PASSWORD
=================================================
*/

# Dyamically create the sign in audience based on the multi_tenancy_enabled var
# Default is "false"
locals {
  # If multi_tenancy_enabled is true -> "AzureADMultipleOrgs", else "AzureADMyOrg"
  sign_in_aud = (var.multi_tenancy_enabled ? "AzureADMultipleOrgs" : "AzureADMyOrg")
}

resource "azuread_application" "wiz_da_scanner" {
  display_name     = var.wiz_da_scanner_app_name
  sign_in_audience = local.sign_in_aud
  owners                       = [data.azuread_client_config.current.object_id]
  api {
    requested_access_token_version = 2
  }
  web {
    homepage_url = "https://app.wiz.io"
  }

  feature_tags {
    custom_single_sign_on = false
    enterprise            = false
    gallery               = false
    hide                  = false
  }
}

resource "azuread_application_password" "wiz_da_scanner_pass" {
  display_name   = "Wiz Disk Analyzer - Scanner"
  application_id = azuread_application.wiz_da_scanner.id
  end_date       = timeadd(formatdate("YYYY-MM-DD'T'00:00:00Z", timestamp()), var.key_expire_end_date_relative) # 24h * 365 days * 10 years
}

resource "azuread_service_principal" "wiz_da_scanner_sp" {
  client_id                    = azuread_application.wiz_da_scanner.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
  feature_tags {
    custom_single_sign_on = false
    enterprise            = false
    gallery               = false
    hide                  = false
  }
}

/*
=================================================
WIZ DISK ANALYZER CONTROL PLANE MANAGED IDENTITY
=================================================
*/

resource "azurerm_user_assigned_identity" "wiz_da_control_plane_identity" {
  count               = var.use_worker_managed_identity ? 1 : 0
  name                = var.wiz_da_control_plane_identity_name
  location            = azurerm_resource_group.wiz_orchestrator_rg.location
  resource_group_name = azurerm_resource_group.wiz_orchestrator_rg.name
}

/*
=================================================
WIZ DISK ANALYZER WORKER APP, SP, PASSWORD
=================================================
*/

resource "azuread_application" "wiz_da_worker" {
  count            = var.use_worker_managed_identity ? 0 : 1
  display_name     = var.wiz_da_worker_app_name
  sign_in_audience = "AzureADMyOrg"
  owners                       = [data.azuread_client_config.current.object_id]
  api {
    requested_access_token_version = 2
  }
  web {
    homepage_url = "https://app.wiz.io"
  }

  feature_tags {
    custom_single_sign_on = false
    enterprise            = false
    gallery               = false
    hide                  = false
  }
}

resource "azuread_application_password" "wiz_da_worker_pass" {
  count          = var.use_worker_managed_identity ? 0 : 1
  display_name   = "Wiz Disk Analyzer - Worker"
  application_id = azuread_application.wiz_da_worker[count.index].id
  end_date       = timeadd(formatdate("YYYY-MM-DD'T'00:00:00Z", timestamp()), var.key_expire_end_date_relative) # 24h * 365 days * 10 years
}

resource "azuread_service_principal" "wiz_da_worker_sp" {
  count                        = var.use_worker_managed_identity ? 0 : 1
  client_id                    = azuread_application.wiz_da_worker[count.index].client_id
  owners                       = [data.azuread_client_config.current.object_id]
  app_role_assignment_required = false
  feature_tags {
    custom_single_sign_on = false
    enterprise            = false
    gallery               = false
    hide                  = false
  }
}

/*
=================================================
WIZ DISK ANALYZER WORKER MANAGED IDENTITY
=================================================
*/

resource "azurerm_user_assigned_identity" "wiz_da_worker_identity" {
  count               = var.use_worker_managed_identity ? 1 : 0
  name                = var.wiz_da_worker_identity_name
  location            = azurerm_resource_group.wiz_orchestrator_rg.location
  resource_group_name = azurerm_resource_group.wiz_orchestrator_rg.name
}
