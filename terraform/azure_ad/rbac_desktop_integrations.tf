# RELOPS-2520 — locked-down on-demand test VMs for Desktop Integrations.
#
# DI need to spin up short-lived VMs across several operating systems to
# reproduce bugs and validate patches. Every other team that needs VMs today
# holds Contributor at subscription scope (see rbac.tf), which grants full
# control of networking, storage, Key Vault and cost exports across the whole
# subscription. This module is the narrow alternative: DI can build and tear
# down VMs inside one resource group and can see nothing else they can act on.
#
# Two roles are used because the Azure portal cannot render a subscription the
# caller has no read access to:
#
#   fx-nonci-desktop-integrations-vm-operator  RG scope   full VM lifecycle
#   fx-nonci-desktop-integrations-browse       sub scope  read-only, list/quota
#
# Escalation is blocked by omission rather than by not_actions alone: the role
# grants no Microsoft.Authorization write, so members cannot grant themselves
# more; and no Microsoft.ManagedIdentity/*/assign/action, so they cannot attach
# an existing managed identity to a VM and inherit its permissions. A
# system-assigned identity created via virtualMachines/write is inert because
# it starts with no role assignments and members cannot create any.

locals {
  # These resource groups are managed in the azure_fx_nonci workspace and are
  # referenced here by constructed resource ID, the same cross-workspace
  # pattern used for the CrowdStrike Event Hub namespace in rbac.tf.
  #
  # rg-west-us-desktop-integrations → azure_fx_nonci/rg-desktop-integrations.tf
  # rg-packer-worker-images         → azure_fx_nonci/worker-images.tf
  fx_nonci_desktop_integrations_rg_id = "/subscriptions/${var.firefox_nonci_subscription_id}/resourceGroups/rg-west-us-desktop-integrations"
  fx_nonci_worker_images_rg_id        = "/subscriptions/${var.firefox_nonci_subscription_id}/resourceGroups/rg-packer-worker-images"
}

# Scoped to the DI resource group. Because "scope" is the RG, assignable_scopes
# defaults to that RG too — the role cannot be assigned anywhere else, even by
# a User Access Administrator who did not read this file.
resource "azurerm_role_definition" "fx_nonci_desktop_integrations_vm_operator" {
  name        = "fx-nonci-desktop-integrations-vm-operator"
  description = "Create, manage and delete VMs within the Desktop Integrations resource group. No RBAC, no identity assignment, no cross-RG reach."
  scope       = local.fx_nonci_desktop_integrations_rg_id

  permissions {
    actions = [
      # read — confined to the RG by the assignment scope
      "Microsoft.Authorization/*/read",
      "Microsoft.Compute/*/read",
      "Microsoft.Insights/*/read",
      "Microsoft.Network/*/read",
      "Microsoft.ResourceHealth/availabilityStatuses/read",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/subscriptions/resourceGroups/resources/read",
      "Microsoft.Storage/*/read",

      # the portal's "Create a virtual machine" wizard submits an ARM
      # deployment; without this the blade fails at the validation step
      "Microsoft.Resources/deployments/*",

      # VM lifecycle
      "Microsoft.Compute/virtualMachines/write",
      "Microsoft.Compute/virtualMachines/delete",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Compute/virtualMachines/powerOff/action",
      "Microsoft.Compute/virtualMachines/deallocate/action",
      "Microsoft.Compute/virtualMachines/redeploy/action",
      "Microsoft.Compute/virtualMachines/reimage/action",

      # runCommand and extensions are both remote-code-execution-as-SYSTEM on
      # the target VM. Included deliberately: members already have interactive
      # OS access to these machines over RDP/SSH, so withholding these removes
      # the lockout-recovery path without removing any capability. They stay
      # contained because the role cannot attach a managed identity.
      "Microsoft.Compute/virtualMachines/runCommand/action",
      "Microsoft.Compute/virtualMachines/extensions/*",

      # disks and snapshots — snapshots let DI capture a reproduction state
      # before destroying a short-lived VM
      "Microsoft.Compute/disks/write",
      "Microsoft.Compute/disks/delete",
      "Microsoft.Compute/disks/beginGetAccess/action",
      "Microsoft.Compute/disks/endGetAccess/action",
      "Microsoft.Compute/snapshots/write",
      "Microsoft.Compute/snapshots/delete",
      "Microsoft.Compute/snapshots/beginGetAccess/action",
      "Microsoft.Compute/snapshots/endGetAccess/action",

      # networking, RG-local only. virtualNetworkPeerings/write is deliberately
      # absent: peering requires write on both sides, so members cannot bridge
      # this sandbox into any RelOps-managed VNet.
      "Microsoft.Network/networkInterfaces/write",
      "Microsoft.Network/networkInterfaces/delete",
      "Microsoft.Network/networkInterfaces/join/action",
      "Microsoft.Network/networkSecurityGroups/write",
      "Microsoft.Network/networkSecurityGroups/delete",
      "Microsoft.Network/networkSecurityGroups/join/action",
      "Microsoft.Network/publicIPAddresses/write",
      "Microsoft.Network/publicIPAddresses/delete",
      "Microsoft.Network/publicIPAddresses/join/action",
      "Microsoft.Network/virtualNetworks/write",
      "Microsoft.Network/virtualNetworks/delete",
      "Microsoft.Network/virtualNetworks/subnets/join/action",
    ]

    # Redundant against the action list above, which grants no Authorization
    # writes. Kept as a second barrier and as a statement of intent: this role
    # must never become self-escalating if the wildcards above are widened.
    not_actions = [
      "Microsoft.Authorization/*/Delete",
      "Microsoft.Authorization/*/Write",
      "Microsoft.Authorization/elevateAccess/Action",
    ]
  }
}

# Subscription-scope read. Without this the subscription does not appear in the
# portal at all and members cannot reach their own resource group through the
# UI. Strictly narrower than the built-in Reader role, which would expose the
# configuration of every resource in FF Non-CI.
#
# MarketplaceOrdering is read-only on purpose. DI need several operating
# systems, and most common Linux images (Ubuntu Server, Debian, RHEL) deploy
# without accepting terms. Images that are term-gated or paid require
# .../sign/action, which is withheld so that DI cannot commit spend on a paid
# Marketplace offer — ask RelOps to accept terms for a specific offer instead.
resource "azurerm_role_definition" "fx_nonci_desktop_integrations_browse" {
  name        = "fx-nonci-desktop-integrations-browse"
  description = "Minimum subscription-level reads required for the Azure portal to render the FF Non-CI subscription and VM size/quota/image pickers."
  scope       = "/subscriptions/${var.firefox_nonci_subscription_id}"

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/read",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Compute/locations/usages/read",
      "Microsoft.Compute/locations/vmSizes/read",
      "Microsoft.Compute/skus/read",
      "Microsoft.Network/locations/*/read",
      "Microsoft.MarketplaceOrdering/agreements/offers/plans/read",
    ]
  }
}

resource "azurerm_role_assignment" "desktop_integrations_vm_operator" {
  scope              = local.fx_nonci_desktop_integrations_rg_id
  role_definition_id = azurerm_role_definition.fx_nonci_desktop_integrations_vm_operator.role_definition_resource_id
  principal_id       = azuread_group.desktop_integrations_vms.object_id
}

resource "azurerm_role_assignment" "desktop_integrations_browse" {
  scope              = "/subscriptions/${var.firefox_nonci_subscription_id}"
  role_definition_id = azurerm_role_definition.fx_nonci_desktop_integrations_browse.role_definition_resource_id
  principal_id       = azuread_group.desktop_integrations_vms.object_id
}

# Read-only on the shared image galleries so DI can deploy the RelOps Windows
# images (win10-64-2009, win11-64-2009, …) instead of rolling their own from
# the Marketplace. Reader here covers
# Microsoft.Compute/galleries/images/versions/read; it grants nothing writable.
resource "azurerm_role_assignment" "desktop_integrations_worker_images_reader" {
  scope                = local.fx_nonci_worker_images_rg_id
  role_definition_name = "Reader"
  principal_id         = azuread_group.desktop_integrations_vms.object_id
}
