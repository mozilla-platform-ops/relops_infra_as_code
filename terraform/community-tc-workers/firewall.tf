resource "google_compute_firewall" "ssh_ingress_from_iap" {
  project       = local.project
  name          = "allow-ssh-ingress-from-iap"
  network       = "default"
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  allow {
    ports    = [22]
    protocol = "tcp"
  }
}