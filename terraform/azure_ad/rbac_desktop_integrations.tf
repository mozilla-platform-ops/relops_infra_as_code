# RELOPS-2520 — VM access for Desktop Integrations, confined to one resource
# group instead of the subscription-scope Contributor other teams hold.

locals {
  # RG is managed in azure_fx_nonci; referenced by constructed ID, the same
  # cross-workspace pattern as the CrowdStrike namespace in rbac.tf.
  fx_nonci_desktop_integrations_rg_id = "/subscriptions/${var.firefox_nonci_subscription_id}/resourceGroups/rg-west-us-desktop-integrations"
}

# scope = the RG, so assignable_scopes defaults to it and the role cannot be
# assigned anywhere else.
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

      # the portal's Create-VM wizard submits an ARM deployment
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

      # RCE-as-SYSTEM on the VM, but members already have RDP/SSH to it and the
      # role cannot attach a managed identity, so this adds no reach.
      "Microsoft.Compute/virtualMachines/runCommand/action",
      "Microsoft.Compute/virtualMachines/extensions/*",

      # disks and snapshots
      "Microsoft.Compute/disks/write",
      "Microsoft.Compute/disks/delete",
      "Microsoft.Compute/disks/beginGetAccess/action",
      "Microsoft.Compute/disks/endGetAccess/action",
      "Microsoft.Compute/snapshots/write",
      "Microsoft.Compute/snapshots/delete",
      "Microsoft.Compute/snapshots/beginGetAccess/action",
      "Microsoft.Compute/snapshots/endGetAccess/action",

      # networking, RG-local. virtualNetworkPeerings/write is omitted: peering
      # needs write on both sides, so no bridging into a RelOps VNet.
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

    # Redundant against the actions above; kept so the role stays non-escalating
    # if those wildcards are ever widened.
    not_actions = [
      "Microsoft.Authorization/*/Delete",
      "Microsoft.Authorization/*/Write",
      "Microsoft.Authorization/elevateAccess/Action",
    ]
  }
}

# The portal cannot render a subscription the caller cannot read. Narrower than
# built-in Reader, which would expose every resource's config in FF Non-CI.
# DI build from Marketplace images to match real-world environments. Terms are
# read-only here — no sign/action, so term-gated or paid offers need RelOps to
# accept terms for that offer.
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
