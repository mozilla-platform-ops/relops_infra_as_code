# Service principal for the third-party multitenant "Splunk Logging" app.
# Required by Microsoft's March 2026 retirement of service-principal-less authentication.
resource "azuread_service_principal" "splunk_logging" {
  client_id    = "31b68eb1-dd36-4317-a95c-9d0e42b18017"
  use_existing = true
}
