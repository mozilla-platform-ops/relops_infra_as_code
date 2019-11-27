resource "vault_policy" "admin" {
  name = "admin"

  policy = file("${path.module}/policies/admin.hcl")
}

resource "vault_policy" "hiera_admin" {
  name = "hiera_admin"

  policy = file("${path.module}/policies/hiera_admin.hcl")
}

