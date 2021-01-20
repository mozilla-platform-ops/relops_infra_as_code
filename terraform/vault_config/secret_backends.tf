resource "vault_mount" "hiera" {
  path        = "hiera"
  type        = "kv"
  description = "Ronin Puppet Hiera Secret Store"
  options = {
    version = 2
  }
}

