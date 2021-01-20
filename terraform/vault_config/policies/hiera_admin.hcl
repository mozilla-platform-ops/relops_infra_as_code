# List, create, update, and delete key/value secrets
path "hiera/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

