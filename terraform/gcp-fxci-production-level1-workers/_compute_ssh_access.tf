# grants SSH access to releng users via IAP tunnel and OS Login

# enable OS Login at the project level
# this allows users with roles/compute.osAdminLogin to SSH without needing
# compute.instances.setMetadata permission (admins retain access via roles/owner)
resource "google_compute_project_metadata_item" "enable_os_login" {
  project = "fxci-production-level1-workers"
  key     = "enable-oslogin"
  value   = "TRUE"
}

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
