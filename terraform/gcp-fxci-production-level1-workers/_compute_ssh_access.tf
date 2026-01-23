# grants SSH access to releng users via IAP tunnel and OS Login

# roles/iap.tunnelResourceAccessor - allows IAP tunnel connections
resource "google_project_iam_member" "releng-users-iap-tunnel" {
  for_each = var.releng_users

  project = "fxci-production-level1-workers"
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "user:${each.value}@mozilla.com"
}

# roles/compute.osAdminLogin - allows SSH with sudo access
resource "google_project_iam_member" "releng-users-os-admin-login" {
  for_each = var.releng_users

  project = "fxci-production-level1-workers"
  role    = "roles/compute.osAdminLogin"
  member  = "user:${each.value}@mozilla.com"
}
