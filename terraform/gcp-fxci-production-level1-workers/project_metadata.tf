resource "google_compute_project_metadata" "level1_workers" {
  metadata = {
    enable-oslogin = "TRUE"
    ssh-keys       = trimspace(file("${path.module}/ssh-keys.txt"))
  }
  project = "fxci-production-level1-workers"
}
