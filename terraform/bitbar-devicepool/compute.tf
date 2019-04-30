resource "google_compute_instance" "vm_instance" {
  count = "${var.host_count}"

  name         = "bitbar-devicepool-${count.index}"
  machine_type = "f1-micro"

  metadata {
    // can take multiple, just separate with "\n"
    sshKeys = "${var.ssh_user}:${var.ssh_key}"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "${google_compute_network.bitbar-net.name}"

    access_config {
      nat_ip = "${element(google_compute_address.ip_address.*.address, count.index)}"
    }
  }
}

resource "google_compute_firewall" "devicepool-firewall" {
  name    = "devicepool-firewall"
  network = "${google_compute_network.bitbar-net.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_network" "bitbar-net" {
  name = "bitbar-net"
}

resource "google_compute_address" "ip_address" {
  count = "${var.host_count}"
  name  = "devicepool-ip-${count.index}"
}
