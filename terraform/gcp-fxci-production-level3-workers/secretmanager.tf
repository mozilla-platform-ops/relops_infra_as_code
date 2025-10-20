resource "google_secret_manager_secret" "cot" {
  secret_id = "cot"
  project   = "fxci-production-level3-workers"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_iam_member" "cot_worker_images" {
  secret_id = google_secret_manager_secret.cot.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${module.google_deployment_accounts.service_account.email}"
}

resource "google_secret_manager_secret_iam_member" "cot_users" {
  for_each = [
    "aerickson",
    "jmoss",
    "mcornmesser",
    "rcurran"
  ]
  project   = "fxci-production-level3-workers"
  member    = "user:${each.value}@mozilla.com"
  secret_id = google_secret_manager_secret.cot.id
  role      = "roles/secretmanager.secretAccessor"
}
