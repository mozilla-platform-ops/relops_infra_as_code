module "google_deployment_accounts" {
  source              = "github.com/mozilla/terraform-modules//google_deployment_accounts?ref=main"
  project             = local.project
  environment         = "prod"
  github_repositories = toset(var.oidc_github_repositories)
  wip_name            = "github-actions"
  wip_project_number  = 324168772199
}

resource "google_project_iam_member" "google_deployment_accounts_compute_admin" {
  project = local.project
  role    = "roles/compute.admin"
  member  = "serviceAccount:${module.google_deployment_accounts.service_account.email}"
}

resource "google_project_iam_member" "google_deployment_accounts_service_account_user" {
  project = local.project
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${module.google_deployment_accounts.service_account.email}"
}

resource "google_project_iam_member" "google_deployment_accounts_iap_user" {
  project = local.project
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "serviceAccount:${module.google_deployment_accounts.service_account.email}"
}