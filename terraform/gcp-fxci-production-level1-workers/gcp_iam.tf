variable "releng_users" {
    type = set(string)
    description = "list of usernames"
}

variable "translations_users" {
    type = set(string)
    description = "list of usernames"
}

# TODO: use this?
# roles/viewer has a ton of permissions, reduce
#   - https://console.cloud.google.com/iam-admin/roles/details/roles%3Cviewer?project=fxci-production-level1-workers
# resource "google_organization_iam_custom_role" "relsre-compute-viewer" {
#   role_id     = "relsre-compute-viewer"
#   org_id      = "887720501152"  # fxci-production-level1-workers
#   title       = "ReleaseSRE 'compute viewer' custom role"
#   description = "a read-only role that allows viewing of compute resources"
#   permissions = ["compute.instances.list", "compute.instances.get"]
# }

# roles/monitoring.viewer
resource "google_project_iam_member" "releng-users-monitoring" {
    for_each = "${var.releng_users}"

  project = "fxci-production-level1-workers"
  role    = "roles/monitoring.viewer"
  member  = "user:${each.value}@mozilla.com"
}

resource "google_project_iam_member" "translations-users-monitoring" {
    for_each = "${var.translations_users}"

  project = "fxci-production-level1-workers"
  role    = "roles/monitoring.viewer"
  member  = "user:${each.value}@mozilla.com"
}

# roles/compute.viewer
resource "google_project_iam_member" "releng-users-compute" {
    for_each = "${var.releng_users}"

  project = "fxci-production-level1-workers"
  role    = "roles/compute.viewer"
  member  = "user:${each.value}@mozilla.com"
}

resource "google_project_iam_member" "translations-users-compute" {
    for_each = "${var.translations_users}"

  project = "fxci-production-level1-workers"
  role    = "roles/compute.viewer"
  member  = "user:${each.value}@mozilla.com"
}

# roles/logging.viewer
resource "google_project_iam_member" "releng-users-logs" {
    for_each = "${var.releng_users}"

  project = "fxci-production-level1-workers"
  role    = "roles/logging.viewer"
  member  = "user:${each.value}@mozilla.com"
}

resource "google_project_iam_member" "translations-users-logs" {
    for_each = "${var.translations_users}"

  project = "fxci-production-level1-workers"
  role    = "roles/logging.viewer"
  member  = "user:${each.value}@mozilla.com"
}

# roles/monitoring.editor
#   (which grants monitoring.dashboards.create among others)
resource "google_project_iam_member" "releng-users-monitoring-editor" {
    for_each = "${var.releng_users}"

  project = "fxci-production-level1-workers"
  role    = "roles/monitoring.editor"
  member  = "user:${each.value}@mozilla.com"
}

resource "google_project_iam_member" "translations-users-monitoring-editor" {
    for_each = "${var.translations_users}"

  project = "fxci-production-level1-workers"
  role    = "roles/monitoring.editor"
  member  = "user:${each.value}@mozilla.com"
}

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