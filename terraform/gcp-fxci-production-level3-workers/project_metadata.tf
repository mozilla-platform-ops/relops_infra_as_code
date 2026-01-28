resource "google_compute_project_metadata" "level3_workers" {
  metadata = {
    ssh-keys = trimspace(file("${path.module}/ssh-keys.txt"))
  }
  project = "fxci-production-level3-workers"
}
