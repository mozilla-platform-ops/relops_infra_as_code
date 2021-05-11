resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_auth_backend" "auth0" {
  type = "oidc"
}
