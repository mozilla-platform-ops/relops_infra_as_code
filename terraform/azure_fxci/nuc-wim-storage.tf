# =============================================================================
# Blob storage for NUC Windows install.wim files. ENTRA-ONLY access model.
#
# The account has a public endpoint open to all networks (NO IP firewall), but:
#   - no anonymous/public blob access, and
#   - shared account keys are DISABLED — every caller must present an Entra
#     identity holding a Storage Blob Data RBAC role (grants below).
# This replaced the earlier IP-allow-list ("Tier 1") posture: split-tunnel VPN
# made per-workstation IP allow-listing unworkable, and Entra RBAC gates access
# regardless of source network.
#
# Callers (all via Entra / azcopy --auth-mode login):
#   - Packer build (worker_images SP)        -> Blob Data Contributor
#   - MDC1 downloader SP                      -> Blob Data Reader (captured only)
#   - Relops group (operators)               -> Blob Data Owner + Contributor
#
# Containers:
#   base     - bring-your-own starting install.wim (uploaded once)
#   captured - baked golden install.wim output by the wim-packer pipeline
#
# Region Central US to co-locate with Packer / the image galleries.
# =============================================================================

# Aliased provider that manages the Blob data plane via Entra (AAD) rather than
# the account key — required because shared_access_key_enabled = false below.
# Scoped to this file's container resources so the rest of azure_fxci (which
# still manages other storage via keys) is unaffected.
provider "azurerm" {
  alias               = "nuc_wim_aad"
  storage_use_azuread = true
  features {}
  subscription_id = "108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"
  tenant_id       = "c0dc8bb0-b616-427e-8217-9513964a145b"
}

variable "relops_group_object_id" {
  type        = string
  description = "Entra object ID of the Relops group. Members get data-plane Blob roles on the WIM store so operators can manage it (e.g. upload the base WIM) with their own Entra identity."
  default     = "cb79b99f-fdaa-4e0d-a2c8-c5841890fa74" # Relops
}

variable "nuc_wim_downloader_object_id" {
  type        = string
  description = "Entra object ID of the SP/managed identity the MDC1 server uses to download (from azure_ad/sp_nuc_wim_downloader.tf output, applied first). Empty = skip the RBAC grant (use SAS instead)."
  # sp-relops-nuc-wim-downloader (azure_ad/sp_nuc_wim_downloader.tf), applied 2026-07-23.
  default = "ae54832f-8931-46d8-8faa-133637e72798"
}

resource "azurerm_resource_group" "nuc-wim" {
  name     = "rg-${local.locationshort}-nuc-wim"
  location = local.location
  tags     = merge(local.common_tags, tomap({ "Name" = "rg-${local.locationshort}-nuc-wim" }))
}

# Dedicated VNet + subnet for Packer builds, with the Storage service endpoint so
# the build VM's traffic is allowed by the storage firewall (no private endpoint).
resource "azurerm_virtual_network" "nuc-wim" {
  name                = "vn-${local.locationshort}-nuc-wim"
  location            = azurerm_resource_group.nuc-wim.location
  resource_group_name = azurerm_resource_group.nuc-wim.name
  address_space       = ["10.20.0.0/24"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "nuc-wim-packer" {
  name                 = "sn-${local.locationshort}-nuc-wim-packer"
  resource_group_name  = azurerm_resource_group.nuc-wim.name
  virtual_network_name = azurerm_virtual_network.nuc-wim.name
  address_prefixes     = ["10.20.0.0/26"]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_storage_account" "nuc-wim" {
  provider                 = azurerm.nuc_wim_aad # keys disabled -> read service props via AAD
  name                     = "nucwimfxci"
  resource_group_name      = azurerm_resource_group.nuc-wim.name
  location                 = azurerm_resource_group.nuc-wim.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Entra-only posture: public endpoint open to all networks, but no anonymous
  # access and NO shared account keys — access is gated purely by Entra RBAC.
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
  shared_access_key_enabled       = false # Entra-only: no account key / SAS

  # No IP firewall — access is controlled by the Storage Blob Data RBAC grants
  # below, which work from any network. (Removed the IP allow-list: split-tunnel
  # VPN made per-workstation IPs unworkable.)
  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }

  tags = merge(local.common_tags, tomap({ "Name" = "nucwimfxci" }))
}

resource "azurerm_storage_container" "base" {
  provider              = azurerm.nuc_wim_aad # manage via AAD (keys disabled)
  name                  = "base"
  storage_account_id    = azurerm_storage_account.nuc-wim.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "captured" {
  provider              = azurerm.nuc_wim_aad # manage via AAD (keys disabled)
  name                  = "captured"
  storage_account_id    = azurerm_storage_account.nuc-wim.id
  container_access_type = "private"
}

# --- Data-plane RBAC (Entra auth; preferred over keys/SAS) ---------------------
# Packer (worker_images SP, object id from keyvault.tf locals) reads base + writes
# captured -> Storage Blob Data Contributor.
resource "azurerm_role_assignment" "packer_wim_rw" {
  scope                = azurerm_storage_account.nuc-wim.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = local.worker_images_object_id
}

# MDC1 downloader (if using Entra auth) reads captured -> Storage Blob Data Reader.
# Scoped to the 'captured' container only. Skipped when object id is empty (SAS path).
resource "azurerm_role_assignment" "mdc1_wim_ro" {
  count                = var.nuc_wim_downloader_object_id == "" ? 0 : 1
  scope                = azurerm_storage_container.captured.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = var.nuc_wim_downloader_object_id
}

# Relops group: full data-plane access so operators can manage the store (upload
# the base WIM, inspect captured output) with their own Entra identity, from any
# network. Owner supersets Contributor; both granted per request.
resource "azurerm_role_assignment" "relops_wim_data_owner" {
  scope                = azurerm_storage_account.nuc-wim.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = var.relops_group_object_id
}

resource "azurerm_role_assignment" "relops_wim_data_contributor" {
  scope                = azurerm_storage_account.nuc-wim.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.relops_group_object_id
}

# The account only uses blob, but with shared keys disabled the azurerm provider
# reads queue + file *service properties* via AAD when refreshing the account
# resource. These grants let whoever runs Terraform (operators in Relops) perform
# those reads; they are not needed for the WIM workflow itself.
resource "azurerm_role_assignment" "relops_wim_queue_tf" {
  scope                = azurerm_storage_account.nuc-wim.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = var.relops_group_object_id
}

resource "azurerm_role_assignment" "relops_wim_file_tf" {
  scope                = azurerm_storage_account.nuc-wim.id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = var.relops_group_object_id
}

# --- Ephemeral build VM identity + workflow SP rights --------------------------
# The GHA workflow (worker_images_fxci SP) spins an ephemeral nested-virt VM up/down
# per build. Rather than granting each fresh VM's identity a blob role at runtime
# (which would need the SP to have role-assignment rights), a user-assigned managed
# identity is created once and pre-granted blob access; the workflow just attaches it.
resource "azurerm_user_assigned_identity" "wim_builder" {
  name                = "id-${local.locationshort}-wim-builder"
  resource_group_name = azurerm_resource_group.nuc-wim.name
  location            = azurerm_resource_group.nuc-wim.location
  tags                = local.common_tags
}

# The attached UAMI is what actually reads base / writes captured during the bake.
resource "azurerm_role_assignment" "wim_builder_blob" {
  scope                = azurerm_storage_account.nuc-wim.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.wim_builder.principal_id
}

# Workflow SP modest rights: create/delete the ephemeral VM + run-command (Contributor
# scoped to this dedicated RG only — notably NOT role-assignment rights) ...
resource "azurerm_role_assignment" "wim_workflow_vm" {
  scope                = azurerm_resource_group.nuc-wim.id
  role_definition_name = "Contributor"
  principal_id         = local.worker_images_object_id
}

# ... and permission to attach the pre-provisioned UAMI to the VM it creates.
resource "azurerm_role_assignment" "wim_workflow_mi_operator" {
  scope                = azurerm_user_assigned_identity.wim_builder.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = local.worker_images_object_id
}

output "nuc_wim_builder_identity_id" {
  description = "Resource ID of the user-assigned identity to attach to build VMs."
  value       = azurerm_user_assigned_identity.wim_builder.id
}

output "nuc_wim_storage_account" {
  value = azurerm_storage_account.nuc-wim.name
}
output "nuc_wim_packer_subnet_id" {
  value = azurerm_subnet.nuc-wim-packer.id
}
