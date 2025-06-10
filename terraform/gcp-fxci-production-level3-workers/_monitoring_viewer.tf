# requested by ahal in https://mozilla-hub.atlassian.net/browse/RELOPS-984
# and https://mozilla-hub.atlassian.net/browse/RELOPS-1047

# prod svc account
resource "google_project_iam_member" "monitoring-viewer-svc-account" {
  project = "fxci-production-level3-workers"
  role = "roles/monitoring.viewer"
  member  = "serviceAccount:fxci-etl@moz-fx-dev-releng.iam.gserviceaccount.com"
}

# dev svc account
resource "google_project_iam_member" "monitoring-viewer-svc-account-dev" {
  project = "fxci-production-level3-workers"
  role = "roles/monitoring.viewer"
  member  = "serviceAccount:fxci-etl-dev@moz-fx-dev-releng.iam.gserviceaccount.com"
}