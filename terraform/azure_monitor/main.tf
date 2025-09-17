#############################################
# Locals
#############################################

locals {
  pools = var.pools
}

#############################################
# Resource Groups
#############################################

# Shared RG (for LAW, Action Group, artifacts, etc.)
resource "azurerm_resource_group" "shared" {
  name     = var.shared_resource_group
  location = var.default_location
  tags     = var.tags
}

# Per-pool RGs
resource "azurerm_resource_group" "pool" {
  for_each = local.pools

  name     = each.value.resource_group_name
  location = each.value.location
  tags     = var.tags
}

#############################################
# Networking (per pool)
#############################################

module "network" {
  for_each = local.pools
  source   = "./modules/network"

  name                = each.key
  location            = each.value.location
  resource_group_name = azurerm_resource_group.pool[each.key].name

  vnet_cidr   = each.value.vnet_cidr
  subnet_cidr = each.value.subnet_cidr
  tags        = var.tags
}

#############################################
# Artifacts (upload init script to Blob + SAS)
#############################################

module "artifacts" {
  source              = "./modules/artifacts"
  name                = var.project_name
  location            = var.default_location
  resource_group_name = azurerm_resource_group.shared.name
  tags                = var.tags

  script_local_path = abspath("${path.root}/scripts/avd-session-init.ps1")
}

#############################################
# Monitoring core (LAW + DCR + Action Group + Alerts)
#############################################

module "monitoring" {
  source              = "./modules/monitoring"
  name                = var.project_name
  location            = var.default_location
  resource_group_name = azurerm_resource_group.shared.name
  tags                = var.tags

  enable_alerts       = true
  create_action_group = true
  alert_emails        = var.alert_emails

  # Scopes may be unknown at plan; module can handle
  session_host_vm_ids = flatten([for k, v in module.session_hosts : try(v.vm_ids, [])])
}

#############################################
# AVD Core (per pool)
#############################################

module "avd_core" {
  for_each = local.pools
  source   = "./modules/avd-core"

  name                = each.key
  location            = each.value.location
  resource_group_name = azurerm_resource_group.pool[each.key].name
  tags                = var.tags

  workspace_resource_id = module.monitoring.workspace_id
  enable_diagnostics    = true

  hostpool_friendly_name         = "${each.key}-hp"
  hostpool_type                  = "Pooled"
  load_balancer_type             = "BreadthFirst"
  max_sessions_per_host          = try(each.value.max_sessions_per_host, 10)
  registration_token_valid_hours = coalesce(each.value.registration_token_valid_hours, 2)
  custom_rdp_properties          = try(each.value.custom_rdp_properties, null)
}

#############################################
# Session Hosts (per pool, optional)
#############################################

module "session_hosts" {
  for_each = { for k, v in local.pools : k => v if coalesce(v.deploy_vms, true) }
  source   = "./modules/session-hosts"

  name                = each.key
  location            = each.value.location
  resource_group_name = azurerm_resource_group.pool[each.key].name
  subnet_id           = module.network[each.key].subnet_id
  hostpool_id         = module.avd_core[each.key].hostpool_id
  registration_token  = module.avd_core[each.key].registration_token
  tags                = var.tags

  vm_count             = each.value.vm_count
  vm_size              = each.value.vm_size
  computer_name_prefix = substr("${each.key}-w11ms", 0, 10)

  # Image (Marketplace or SIG)
  image     = try(each.value.image, null)
  sig_image = try(each.value.sig_image, null)

  admin_username = var.admin_username
  admin_password = var.admin_password

  enable_aad_login  = true
  init_script_uri   = module.artifacts.script_blob_sas_url
  enable_laps_local = try(each.value.enable_laps_local, true)

  # Pass DCR ID so the module can make per-VM associations
  dcr_id                 = module.monitoring.dcr_id
  enable_dcr_association = true
}

#############################################
# Scaling Plans (per pool)
#############################################

module "scaling" {
  for_each = local.pools
  source   = "./modules/scaling"

  name                = each.key
  location            = each.value.location
  resource_group_name = azurerm_resource_group.pool[each.key].name
  host_pool_id        = module.avd_core[each.key].hostpool_id
  tags                = var.tags

  # Defaults to always-on; set provide_schedules=true and pass schedules to change
}

#############################################
# IAM Assignments (per pool)
#############################################

module "iam_assignments" {
  for_each = local.pools
  source   = "./modules/iam-assignments"

  app_group_id  = module.avd_core[each.key].app_group_id
  principal_ids = var.principal_ids
}
