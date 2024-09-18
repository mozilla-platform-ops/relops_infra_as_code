# This Terraform configuration file's goal is to assign IAM roles to github actions.

module "google_deployment_accounts" {
  source              = "github.com/mozilla/terraform-modules//google_deployment_accounts?ref=main"
  project             = "taskcluster-imaging"
  environment         = "prod"
  github_repositories = toset(var.oidc_github_repositories)
  wip_name            = "github-actions"
  wip_project_number  = 324168772199
}

# google_project_iam_binding is authoritative, so DO NOT USE IT!
# - it will wipe out all other users of that role

resource "google_project_iam_member" "google_deployment_accounts_compute_admin" {
  project = "taskcluster-imaging"
  role    = "roles/compute.admin"
  member  = "serviceAccount:${module.google_deployment_accounts.service_account.email}"
}

resource "google_project_iam_member" "google_deployment_accounts_service_account_user" {
  project = "taskcluster-imaging"
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${module.google_deployment_accounts.service_account.email}"
}