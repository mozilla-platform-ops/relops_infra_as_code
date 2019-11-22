variable "puppet_roles" {
  type = list(string)
  default = [
    "mac_v3_signing_ff_prod",
    "mac_v3_signing_tb_prod",
    "mac_v3_signing_dep",
    "gecko_t_osx_1014",
    "gecko_t_osx_1014_staging",
  ]
}

resource "vault_policy" "puppet_role_generic" {
  for_each = toset(var.puppet_roles)
  name     = "puppet_role_${each.value}"

  policy = templatefile("${path.module}/policies/puppet_role_template.hcl.tpl", { puppet_role = each.value })
}

resource "vault_approle_auth_backend_role" "approle_puppet_roles" {
  for_each = toset(var.puppet_roles)

  backend               = vault_auth_backend.approle.path
  role_name             = each.value
  secret_id_bound_cidrs = ["10.49.0.0/16", "10.51.0.0/16"]
  token_bound_cidrs     = ["10.49.56.0/22", "10.51.56.0/22"]
  token_policies        = ["puppet_role_${each.value}"]
}

