resource "vault_audit" "stdout" {
  type = "file"
  path = "file"

  # We write logs to stdout since vault executes in docker container.
  # The logs are then piped to cloud watch.
  description = "Write logs to stdout which are then routed to cloudwatch"
  options = {
    file_path     = "stdout"
    hmac_accessor = false
  }
}
