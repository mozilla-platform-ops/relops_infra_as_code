resource "google_secret_manager_secret" "fake_cot" {
  secret_id = "cot"
  project   = "taskcluster-imaging"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_iam_member" "fake_cot_worker_images" {
  secret_id = google_secret_manager_secret.fake_cot.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${module.google_deployment_accounts.service_account.email}"
}

resource "google_secret_manager_secret_iam_member" "fake_cot_users" {
  for_each = toset([
    "aerickson",
    "jmoss",
    "mcornmesser",
    "rcurran"
  ])
  project   = "taskcluster-imaging"
  member    = "user:${each.value}@mozilla.com"
  secret_id = google_secret_manager_secret.fake_cot.id
  role      = "roles/secretmanager.secretAccessor"
}
