# required for worker-manager to be able to do anything in GCP
resource "google_project_iam_member" "worker-manager-compute-admin" {
  project = "fxci-production-level3-workers"
  role    = "roles/compute.admin"
  member  = "serviceAccount:taskcluster-worker-manager@fxci-production-level3-workers.iam.gserviceaccount.com"
}

# TODO:
# - taskcluster-worker@fxci-production-level1-workers.iam.gserviceaccount.com
# - deploy-prod@fxci-production-level1-workers.iam.gserviceaccount.com