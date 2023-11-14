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
