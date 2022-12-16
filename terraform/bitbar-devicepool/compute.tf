resource "google_compute_disk" "vm_disk" {
  name  = "bitbar-devicepool-disk-${count.index}"
  count = var.host_count
  size  = "25"
  # projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20220924
  image = "ubuntu-2204-lts"
  lifecycle {
    # don't recreate all disks when this changes, manually `-replace`
    ignore_changes = [
      image
    ]
  }
}

resource "google_compute_instance" "vm_instance" {
  count = var.host_count

  name         = "bitbar-devicepool-${count.index}"
  machine_type = "n1-standard-2"

  metadata = {
    # can take multiple, just separate with "\n"
    sshKeys = "${var.ssh_user}:${var.ssh_key}"
  }

  boot_disk {
    auto_delete = false
    source      = element(google_compute_disk.vm_disk.*.self_link, count.index)
  }

  network_interface {
    # A default network is created for all GCP projects
    network = google_compute_network.bitbar-net.name

    access_config {
      nat_ip = element(google_compute_address.ip_address.*.address, count.index)
    }
  }
}

resource "google_compute_firewall" "devicepool-firewall" {
  name    = "devicepool-firewall"
  network = google_compute_network.bitbar-net.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  # restricted to vpn
  source_ranges = data.terraform_remote_state.base.outputs.mozilla_vpn_netblocks
}

resource "google_compute_network" "bitbar-net" {
  name = "bitbar-net"
}

resource "google_compute_address" "ip_address" {
  count = var.host_count
  name  = "devicepool-ip-${count.index}"
}

resource "aws_route53_record" "devicepool" {
  count = var.host_count

  zone_id = data.aws_route53_zone.relops_mozops_net.zone_id
  name    = "devicepool-${count.index}.relops.mozops.net"
  type    = "A"
  ttl     = "3600"
  records = [element(google_compute_address.ip_address.*.address, count.index)]
}

