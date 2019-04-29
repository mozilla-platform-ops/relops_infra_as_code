resource "google_compute_instance" "vm_instance" {
  count = 1

  name         = "bitbar-devicepool-${count.index}"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network       = "default"
    access_config = {}
  }
}
