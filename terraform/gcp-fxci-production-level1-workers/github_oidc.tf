module "google_deployment_accounts" {
  source              = "github.com/mozilla/terraform-modules//google_deployment_accounts?ref=main"
  project             = "fxci-production-level1-workers"
  environment         = "prod"
  github_repositories = toset(var.oidc_github_repositories)
  wip_name            = "github-actions"
  wip_project_number  = 324168772199
}

resource "google_project_iam_binding" "compute_admin" {
  project = "fxci-production-level1-workers"
  role    = "roles/compute.admin"
  members = ["serviceAccount:${module.google_deployment_accounts.service_account.email}"]
}
