import {
  id = "fxci-production-level1-workers"
  to = google_compute_project_metadata.level1_workers
}

resource "google_compute_project_metadata" "level1_workers" {
  metadata = {
    enable-oslogin = "TRUE"
    ssh-keys       = trimspace(file("${path.module}/ssh-keys.txt"))
    startup-script = file("${path.module}/startup-script.sh")
  }
  project = "fxci-production-level1-workers"
}
