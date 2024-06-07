# requested by ahal in https://mozilla-hub.atlassian.net/browse/RELOPS-984

# So could someone please grant the Monitoring Viewer role to the
# fxci-etl@moz-fx-dev-releng.iam.gserviceaccount.com service account?
# In both the fxci-production-level1-workers and fxci-production-level3-workers projects.

resource "google_project_iam_member" "monitoring-viewer-svc-account" {
  project = "fxci-production-level1-workers"
  role = "roles/monitoring.viewer"
  member  = "user:fxci-etl@moz-fx-dev-releng.iam.gserviceaccount.com"
}