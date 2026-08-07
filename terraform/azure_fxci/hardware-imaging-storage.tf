# =============================================================================
# PHASE 1 of the nuc-wim -> hardware-imaging migration: CREATE the new
# 'hardwareimaging' account ALONGSIDE the existing 'nucwimfxci' (nuc-wim-storage.tf
# still holds the old stack). No destroys — the old account + its blobs stay put so
# data can be azcopy-migrated into the new account first.
#
# After migration + worker-images cutover, the old stack is retired and these
# resources fold back into nuc-wim-storage.tf (the end-state config = PR #316):
#   - `terraform state mv azurerm_storage_container.captured_hwimg
#      azurerm_storage_container.captured`  (preserve migrated data on relabel)
#   - the relops_hwimg_* role assignments carry NO data, so they simply recreate.
# Shares the aliased provider (azurerm.nuc_wim_aad), variables, and module locals
# defined in nuc-wim-storage.tf.
# =============================================================================

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
