import {
  id = "fxci-production-level3-workers"
  to = google_compute_project_metadata.level3_workers
}

resource "google_compute_project_metadata" "level3_workers" {
  metadata = {
    ssh-keys       = trimspace(file("${path.module}/ssh-keys.txt"))
    startup-script = file("${path.module}/startup-script.sh")
  }
  project = "fxci-production-level3-workers"
}
