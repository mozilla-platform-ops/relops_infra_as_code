# Naming: <prefix>-<region>-agents
locals {
  region_suffix = replace(lower(var.location), "/[^a-z0-9]/", "")
  base_name     = "${var.prefix}-${local.region_suffix}-agents"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${local.base_name}-rg"
  location = var.location
}

# Network
module "network" {
  source              = "./modules/network"
  name                = local.base_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  vnet_cidr           = var.vnet_cidr
  subnet_cidr         = var.subnet_cidr
}

# AVD Core (host pool, app group, workspace, registration token)
module "avd" {
  source                = "./modules/avd-core"
  name                  = local.base_name
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  max_sessions          = 20
  custom_rdp_properties = "redirectclipboard:i:0 drivestoredirect:s: redirectprinters:i:0 redirectcomports:i:0 redirectsmartcards:i:0 usbdevicestoredirect:s: camerastoredirect:s: audiocapturemode:i:0 devicestoredirect:s: enablerdumultimon:i:1"
  # token_valid_for      = "4h"  # default already 4h in module; uncomment to be explicit
}

# Scaling plan (logic retained; pinned to keep 100% of hosts online)
module "scaling" {
  source              = "./modules/scaling"
  name                = local.base_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  host_pool_id        = module.avd.host_pool_id
  time_zone           = "Pacific Standard Time"
}

# Init script (stateless; no FSLogix)
locals {
  init_script = templatefile("${path.module}/scripts/avd-sessionhost-init.ps1", {
    registration_token = module.avd.registration_token
  })
  init_script_b64 = base64encode(local.init_script)
}

# Session Hosts (optional via deploy_vms)
module "session_hosts" {
  source = "./modules/session-hosts"
  count  = var.deploy_vms ? 1 : 0

  name                = local.base_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.network.subnet_id

  vm_count = var.vm_count
  vm_size  = var.vm_size

  # Bootstrap creds via TF_VAR_ env vars (short-lived; rotated by LAPS)
  admin_username = var.admin_username
  admin_password = var.admin_password

  init_script_b64 = local.init_script_b64

  # AAD login + LAPS (no-Intune path active)
  enable_laps              = true
  laps_managed_by_intune   = false
  laps_backup_directory    = 1
  laps_password_age_days   = 14
  laps_password_length     = 24
  laps_password_complexity = 4
  laps_admin_account_name  = null
}

# Ephemeral registration token revoke flow (requires Azure CLI)
resource "time_sleep" "wait_for_session_host_registration" {
  count           = var.deploy_vms ? 1 : 0
  create_duration = "5m"
  depends_on      = [module.session_hosts]
}

resource "null_resource" "revoke_avd_registration_token" {
  count = var.deploy_vms ? 1 : 0

  triggers = {
    host_pool_id = module.avd.host_pool_id
    token_hash   = sha1(nonsensitive(module.avd.registration_token))
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-lc"]
    command     = "az desktopvirtualization hostpool revoke-registration-token --ids ${module.avd.host_pool_id}"
  }

  depends_on = [time_sleep.wait_for_session_host_registration]
}

# Diagnostics (Log Analytics)
module "diagnostics" {
  source              = "./modules/diagnostics"
  name                = local.base_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  host_pool_id        = module.avd.host_pool_id
}

# IAM: assign Desktop Virtualization User on App Group
module "iam" {
  source        = "./modules/iam-assignments"
  app_group_id  = module.avd.app_group_id
  principal_ids = var.principal_ids
}