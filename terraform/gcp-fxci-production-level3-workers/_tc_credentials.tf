# required for worker-manager to be able to do anything in GCP
resource "google_project_iam_member" "worker-manager-compute-admin" {
  project = "fxci-production-level3-workers"
  role    = "roles/compute.admin"
  member  = "serviceAccount:taskcluster-worker-manager@fxci-production-level3-workers.iam.gserviceaccount.com"
}