# requested by ahal in https://mozilla-hub.atlassian.net/browse/RELOPS-532

resource "google_project_iam_member" "releng-users-tech-support-editor" {
    for_each = "${var.releng_users}"

  project = "fxci-production-level3-workers"
  role    = "roles/cloudsupport.techSupportEditor"
  member  = "user:${each.value}@mozilla.com"
}