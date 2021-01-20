# Login with AppRole
path "auth/approle/login" {
  capabilities = [ "create", "read" ]
}

# Read data
# Set the path to "secret/data/mysql/*" if you are running `kv-v2`
path "hiera/data/common/*" {
  capabilities = [ "read" ]
}

path "hiera/data/roles/${puppet_role}/*" {
  capabilities = [ "read" ]
}
