# This file overrides default variable values defined in variables.tf.
# Do NOT place secrets here (e.g., admin passwords). Secrets must be injected via TF_VAR_ env vars.

# Grant AVD access to an existing Entra ID security group by object ID
principal_ids = [
  "b6f616f1-77b3-4337-b485-bf8ee0e5e934"
]

# Leave other values at their defaults for now
# prefix         = "avd-secure"
# location       = "eastus"
# resource_group = "rg-avd-secure"
# vnet_cidr      = "10.90.0.0/16"
# subnet_cidr    = "10.90.1.0/24"
# vm_count       = 2
# vm_size        = "Standard_D8s_v5"
# deploy_vms     = false