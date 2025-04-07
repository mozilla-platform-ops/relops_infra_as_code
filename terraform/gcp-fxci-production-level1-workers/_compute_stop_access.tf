# bhearsum wants compute.instances.stop for spot instance termination testing
# RELOPS-1415
resource "google_project_iam_custom_role" "custom_role_stop_compute_instances" {
  role_id     = "relops_compute_instance_stop"
  title       = "Relops Compute instance stop role"
  description = "A role that allows compute.instances.stop"
  permissions = ["compute.instances.stop"]
}

resource "google_project_iam_member" "bhearsum-compute-stop-instances" {
  project = "fxci-production-level1-workers"
  role    = google_project_iam_custom_role.custom_role_stop_compute_instances.name
  member  = "user:bhearsum@mozilla.com"
}
