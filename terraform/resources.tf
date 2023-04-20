locals {
  # common_tags should be included in all resources
  common_tags = {
    # Always true; it's why we're here
    terraform        = "true"
    project_name     = var.tag_project_name
    production_state = var.tag_production_state
    owner_email      = var.tag_owner_email
    source_repo_url  = "https://github.com/mozilla-platform-ops/relops_infra_as_code"
  }
}

#######

# TODO: put `project = "translations-sandbox"` in a variable


## service accounts

resource "google_service_account" "tc_worker" {
  account_id   = "taskcluster-worker"
  display_name = "taskcluster worker"
  project      = "translations-sandbox"
}

resource "google_service_account" "tc_worker_manager" {
  account_id   = "taskcluster-worker-manager"
  display_name = "taskcluster worker manager"
  project      = "translations-sandbox"
}

## assign rights to service accounts
# - roles taken from existing service accounts in l1 gcp project

# for worker

resource "google_project_iam_member" "tc_worker_binding_log_writer" {
  project = "translations-sandbox"
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.tc_worker.email}"
}

resource "google_project_iam_member" "tc_worker_binding_metric_writer" {
  project = "translations-sandbox"
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.tc_worker.email}"
}

# for worker_manager

resource "google_project_iam_member" "tc_worker_manager_binding_compute_admin" {
  project = "translations-sandbox"
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.tc_worker_manager.email}"
}

resource "google_project_iam_member" "tc_worker_manager_binding_service_account" {
  project = "translations-sandbox"
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.tc_worker_manager.email}"
}

## keys

# to extract key:
#   `tc show` and save private key contents to file, then run `base64 -D FILE`

resource "google_service_account_key" "tc_worker_key" {
  service_account_id = google_service_account.tc_worker.name
}

resource "google_service_account_key" "tc_worker_manager_key" {
  service_account_id = google_service_account.tc_worker_manager.name
}

