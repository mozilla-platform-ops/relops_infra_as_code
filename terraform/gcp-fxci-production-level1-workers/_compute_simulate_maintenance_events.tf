# bhearsum wants compute.instances.simulateMaintenanceEvent for spot instance termination testing

# the two pre-existing roles with this perm have too much, create a custom role
resource "google_project_iam_custom_role" "my-custom-role" {
  role_id     = "relops_compute_simulate_maintenance"
  title       = "Relops Compute Simulate Maintenance Role"
  description = "A role that allows compute.instances.simulateMaintenanceEvent"
  permissions = ["compute.instances.simulateMaintenanceEvent"]
}

resource "google_project_iam_member" "bhearsum-compute-simulate-maintenance" {
  project = "fxci-production-level1-workers"
  # role    = "roles/compute.instances.simulateMaintenanceEvent"
  role = "projects/fxci-production-level1-workers/roles/relops_compute_simulate_maintenance"
  member  = "user:bhearsum@mozilla.com"
}