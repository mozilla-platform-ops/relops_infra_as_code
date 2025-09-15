# ------------------------------------------------------------
# Locals
# ------------------------------------------------------------
locals {
  # Normalize pool keys for naming (e.g., "westus2" -> "westus2")
  clean = { for k, v in var.pools : k => replace(lower(k), "/[^a-z0-9]/", "") }

  # Per-logon session init script
  session_init     = file("${path.module}/scripts/avd-session-init.ps1")
  session_init_b64 = base64encode(local.session_init)

  # Only pools that should deploy session host VMs
  vm_enabled_pools = {
    for k, v in var.pools :
    k => v if lookup(v, "deploy_vms", true)
  }
}

# ------------------------------------------------------------
# Resource Groups (one per pool)
# ------------------------------------------------------------
resource "azurerm_resource_group" "rg" {
  for_each = var.pools
  name     = "${var.prefix}-${local.clean[each.key]}-agents-rg"
  location = each.value.location
}

# ------------------------------------------------------------
# Network (one per pool)
# ------------------------------------------------------------
module "network" {
  for_each            = var.pools
  source              = "./modules/network"
  name                = "${var.prefix}-${local.clean[each.key]}-agents"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name

  vnet_cidr   = each.value.vnet_cidr
  subnet_cidr = each.value.subnet_cidr
}

# ------------------------------------------------------------
# AVD Core (host pool, app group, workspace) per pool
# ------------------------------------------------------------
module "avd" {
  for_each            = var.pools
  source              = "./modules/avd-core"
  name                = "${var.prefix}-${local.clean[each.key]}-agents"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  max_sessions        = 20

  # Shorten token TTL to limit exposure while we skip explicit revocation for now
  registration_token_valid_hours = 1 # <-- ensure var exists in modules/avd-core

  # RDP lockdown (semicolon-separated—no spaces)
  custom_rdp_properties = "redirectclipboard:i:0;redirectprinters:i:0;redirectcomports:i:0;redirectsmartcards:i:0;drivestoredirect:s:;usbdevicestoredirect:s:;camerastoredirect:s:;audiocapturemode:i:0;enablerdumultimon:i:1"
}

# ------------------------------------------------------------
# Scaling Plan per pool (kept 100% hosts online for now)
# ------------------------------------------------------------
module "scaling" {
  for_each            = var.pools
  source              = "./modules/scaling"
  name                = "${var.prefix}-${local.clean[each.key]}-agents"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  host_pool_id        = module.avd[each.key].host_pool_id
  time_zone           = "Pacific Standard Time"
}

# ------------------------------------------------------------
# Session Hosts (only for pools with deploy_vms = true)
# ------------------------------------------------------------
module "session_hosts" {
  for_each = local.vm_enabled_pools
  source   = "./modules/session-hosts"

  name                = "${var.prefix}-${local.clean[each.key]}-agents"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  subnet_id           = module.network[each.key].subnet_id

  vm_count = each.value.vm_count
  vm_size  = each.value.vm_size

  # Bootstrap creds (password via TF_VAR_admin_password)
  admin_username = var.admin_username
  admin_password = var.admin_password

  # Per-logon script
  init_script_b64 = local.session_init_b64

  # Marketplace pin (optional; module falls back to latest if null)
  image_version = try(each.value.image_version, null)

  # LAPS (no Intune path active)
  enable_laps              = true
  laps_managed_by_intune   = false
  laps_backup_directory    = 1
  laps_password_age_days   = 14
  laps_password_length     = 24
  laps_password_complexity = 4
  laps_admin_account_name  = null
}

# ------------------------------------------------------------
# Diagnostics (Log Analytics + diag settings) per pool
# ------------------------------------------------------------
module "diagnostics" {
  for_each            = var.pools
  source              = "./modules/diagnostics"
  name                = "${var.prefix}-${local.clean[each.key]}-agents"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  host_pool_id        = module.avd[each.key].host_pool_id
}

# ------------------------------------------------------------
# IAM: Desktop Virtualization User on App Group per pool
# ------------------------------------------------------------
module "iam" {
  for_each      = var.pools
  source        = "./modules/iam-assignments"
  app_group_id  = module.avd[each.key].app_group_id
  principal_ids = var.principal_ids
}

# ------------------------------------------------------------
# Optional: (TEMP DISABLED) revoke host pool registration token
# We’re relying on a short 1h TTL. Uncomment when the API path is stable.
# ------------------------------------------------------------
# resource "time_sleep" "wait_for_session_host_registration" {
#   for_each        = local.vm_enabled_pools
#   create_duration = "5m"
#   depends_on      = [module.session_hosts]
# }
#
# resource "null_resource" "revoke_avd_registration_token" {
#   for_each = local.vm_enabled_pools
#
#   triggers = {
#     host_pool_id = module.avd[each.key].host_pool_id
#     token_hash   = sha1(nonsensitive(module.avd[each.key].registration_token))
#   }
#
#   # Option A: az desktopvirtualization (requires extension)
#   # provisioner "local-exec" {
#   #   interpreter = ["bash", "-lc"]
#   #   command = <<-EOC
#   #     set -euo pipefail
#   #     az extension show -n desktopvirtualization >/dev/null 2>&1 || az extension add -n desktopvirtualization -y
#   #     az desktopvirtualization hostpool update --ids ${module.avd[each.key].host_pool_id} \
#   #       --registration-info token-operation=Delete
#   #   EOC
#   # }
#
#   # Option B: az rest (no extension)
#   # provisioner "local-exec" {
#   #   interpreter = ["bash", "-lc"]
#   #   command = <<-EOC
#   #     set -euo pipefail
#   #     az rest --method post \
#   #       --uri "https://management.azure.com${module.avd[each.key].host_pool_id}/revokeRegistrationToken?api-version=2024-04-03"
#   #   EOC
#   # }
#
#   # depends_on = [time_sleep.wait_for_session_host_registration]
# }
