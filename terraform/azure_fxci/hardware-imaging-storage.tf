# =============================================================================
# The 'hardwareimaging' store: sources (resources/), build outputs (captured/) and
# legacy-images/, plus the build VNet/subnet and the Packer build identity.
#
# PHASE 2 of the nuc-wim -> hardware-imaging migration, completing the phase-1
# create-alongside (#317). The old 'nucwimfxci' stack and its file
# (nuc-wim-storage.tf) are REMOVED: every blob it held now has a counterpart here
# (resources/WIMs/, resources/ISOs/, resources/drivers/, resources/tools/,
# captured/WIMs/, captured/ISOs/) and worker-images has been building against this
# account since 2026-08-11.
#
# The phase-1 header proposed also renaming the resource addresses back
# (`state mv captured_hwimg -> captured`, dropping the _hwimg suffixes). That is
# deliberately NOT done: it is cosmetic, needs hand-run `terraform state mv` for
# every address, and would add risk to a change that already destroys a storage
# account. The _hwimg names stay.
#
# This file now owns the aliased AAD provider and the two object-id variables that
# used to live in nuc-wim-storage.tf.
# =============================================================================

# Storage data-plane calls go through Entra, not account keys — the account has
# shared_access_key_enabled = false. Aliased so the rest of azure_fxci (which still
# manages other storage via keys) is unaffected.
provider "azurerm" {
  alias               = "nuc_wim_aad"
  storage_use_azuread = true
  features {}
  subscription_id = "108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"
  tenant_id       = "c0dc8bb0-b616-427e-8217-9513964a145b"
}

variable "relops_group_object_id" {
  type        = string
  description = "Entra object ID of the Relops group. Members get data-plane Blob roles on the imaging store so operators can manage it (e.g. upload a base WIM) with their own Entra identity."
  default     = "cb79b99f-fdaa-4e0d-a2c8-c5841890fa74" # Relops
}

variable "nuc_wim_downloader_object_id" {
  type        = string
  description = "Entra object ID of the SP/managed identity the MDC1 server uses to download captured images (from azure_ad/sp_nuc_wim_downloader.tf output, applied first). Empty = skip the RBAC grant (use SAS instead)."
  # sp-relops-nuc-wim-downloader (azure_ad/sp_nuc_wim_downloader.tf), applied 2026-07-23.
  default = "ae54832f-8931-46d8-8faa-133637e72798"
}

resource "azurerm_resource_group" "hardware-imaging" {
  name     = "rg-${local.locationshort}-hardware-imaging"
  location = local.location
  tags     = merge(local.common_tags, tomap({ "Name" = "rg-${local.locationshort}-hardware-imaging" }))
}

resource "azurerm_storage_account" "hardware-imaging" {
  provider                 = azurerm.nuc_wim_aad # keys disabled -> read service props via AAD
  name                     = "hardwareimaging"
  resource_group_name      = azurerm_resource_group.hardware-imaging.name
  location                 = azurerm_resource_group.hardware-imaging.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Same Entra-only posture as nucwimfxci.
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
  shared_access_key_enabled       = false

  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }

  tags = merge(local.common_tags, tomap({ "Name" = "hardwareimaging" }))
}

# Relops group: data-plane access on the NEW account (operator + azcopy migration),
# plus Queue/File Data so Terraform can read service properties via AAD (keys off).
resource "azurerm_role_assignment" "relops_hwimg_owner" {
  scope                = azurerm_storage_account.hardware-imaging.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = var.relops_group_object_id
}

resource "azurerm_role_assignment" "relops_hwimg_queue" {
  scope                = azurerm_storage_account.hardware-imaging.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = var.relops_group_object_id
}

resource "azurerm_role_assignment" "relops_hwimg_file" {
  scope                = azurerm_storage_account.hardware-imaging.id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = var.relops_group_object_id
}

# Containers (migration targets). depends_on the Blob Data role so creation via the
# AAD provider doesn't race RBAC propagation on the freshly-made account.
resource "azurerm_storage_container" "resources" {
  provider              = azurerm.nuc_wim_aad
  name                  = "resources" # SOURCES: WIMs/ ISOs/ drivers/ tools/
  storage_account_id    = azurerm_storage_account.hardware-imaging.id
  container_access_type = "private"
  depends_on            = [azurerm_role_assignment.relops_hwimg_owner]
}

resource "azurerm_storage_container" "captured_hwimg" {
  provider              = azurerm.nuc_wim_aad
  name                  = "captured" # OUTPUTS: WIMs/ ISOs/  (state mv -> .captured at retire)
  storage_account_id    = azurerm_storage_account.hardware-imaging.id
  container_access_type = "private"
  depends_on            = [azurerm_role_assignment.relops_hwimg_owner]
}

resource "azurerm_storage_container" "legacy_images" {
  provider              = azurerm.nuc_wim_aad
  name                  = "legacy-images" # old, previously-built images
  storage_account_id    = azurerm_storage_account.hardware-imaging.id
  container_access_type = "private"
  depends_on            = [azurerm_role_assignment.relops_hwimg_owner]
}

# --- Compute side (for the ephemeral build VM to run in the new RG) -------------
# Added so a smoke-test build can run against the new stack before the old one is
# retired. End-state labels (no clash with old nuc-wim); role labels de-clashed.
resource "azurerm_virtual_network" "hardware-imaging" {
  name                = "vn-${local.locationshort}-hardware-imaging"
  location            = azurerm_resource_group.hardware-imaging.location
  resource_group_name = azurerm_resource_group.hardware-imaging.name
  address_space       = ["10.20.0.0/24"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "hardware-imaging-packer" {
  name                 = "sn-${local.locationshort}-hardware-imaging-packer"
  resource_group_name  = azurerm_resource_group.hardware-imaging.name
  virtual_network_name = azurerm_virtual_network.hardware-imaging.name
  address_prefixes     = ["10.20.0.0/26"]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_user_assigned_identity" "hardware_imaging_builder" {
  name                = "id-${local.locationshort}-hardware-imaging-builder"
  resource_group_name = azurerm_resource_group.hardware-imaging.name
  location            = azurerm_resource_group.hardware-imaging.location
  tags                = local.common_tags
}

# UAMI reads resources / writes captured during the bake.
resource "azurerm_role_assignment" "hwimg_builder_blob" {
  scope                = azurerm_storage_account.hardware-imaging.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.hardware_imaging_builder.principal_id
}

# Packer/worker_images SP: blob rw on the new account.
resource "azurerm_role_assignment" "packer_hwimg_rw" {
  scope                = azurerm_storage_account.hardware-imaging.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = local.worker_images_object_id
}

# MDC1 downloader SP reads build outputs -> Storage Blob Data Reader, scoped to the
# 'captured' container only. This grant previously existed ONLY on the retired
# nucwimfxci account, so between the phase-1 cutover and this change the SP had no
# access to the account the images actually live in. Skipped when the object id is
# empty (SAS path).
resource "azurerm_role_assignment" "mdc1_hwimg_ro" {
  count                = var.nuc_wim_downloader_object_id == "" ? 0 : 1
  scope                = azurerm_storage_container.captured_hwimg.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = var.nuc_wim_downloader_object_id
}

# Workflow SP: create/delete VM in the new RG + attach the new UAMI.
resource "azurerm_role_assignment" "wim_workflow_vm_hwimg" {
  scope                = azurerm_resource_group.hardware-imaging.id
  role_definition_name = "Contributor"
  principal_id         = local.worker_images_object_id
}

resource "azurerm_role_assignment" "wim_workflow_mi_operator_hwimg" {
  scope                = azurerm_user_assigned_identity.hardware_imaging_builder.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = local.worker_images_object_id
}
