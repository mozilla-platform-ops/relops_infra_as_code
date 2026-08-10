# terraform reference
#   https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
#   https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network

# TODO: not possible to remove default rules... really should make new non-default network and use it for instances...

# not needed, just use "default"
# resource "google_compute_network" "default" {
#   name = "default"
#   project = "translations-sandbox"
# }

# TODO: replicate l1's rules
#   see https://console.cloud.google.com/networking/firewalls/list?project=fxci-production-level1-workers&supportedpurview=project

resource "google_compute_firewall" "allow-livelog" {
  name        = "default-allow-livelog"
  network     = "default"
  description = "TF_MANAGED, Allow livelog connections (https://bugzilla.mozilla.org/show_bug.cgi?id=1607241)"

  allow {
    protocol = "tcp"
    ports    = ["32768-65535"]
  }

  source_ranges = ["0.0.0.0/0"]
  priority      = 1000
}


# {
#   "allowed": [
#     {
#       "IPProtocol": "tcp",
#       "ports": [
#         "0-65535"
#       ]
#     },
#     {
#       "IPProtocol": "udp",
#       "ports": [
#         "0-65535"
#       ]
#     },
#     {
#       "IPProtocol": "icmp"
#     }
#   ],
#   "creationTimestamp": "2019-10-13T22:52:00.375-07:00",
#   "description": "Allow internal traffic on the default network",
#   "direction": "INGRESS",
#   "disabled": false,
#   "enableLogging": false,
#   "id": "3319068565822878703",
#   "kind": "compute#firewall",
#   "logConfig": {
#     "enable": false
#   },
#   "name": "default-allow-internal",
#   "network": "projects/fxci-production-level1-workers/global/networks/default",
#   "priority": 65534,
#   "selfLink": "projects/fxci-production-level1-workers/global/firewalls/default-allow-internal",
#   "sourceRanges": [
#     "10.128.0.0/9"
#   ]
# }

resource "google_compute_firewall" "allow-all-from-vpn" {
  name        = "default-allow-all-from-vpn"
  network     = "default"
  description = "TF_MANAGED"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  # from ../vault/lb.tf
  source_ranges = [
    "10.48.240.0/23", # MDC1 VPN prod udp
    "10.48.242.0/23", # MDC1 VPN prod tcp
    "10.64.0.0/16",   # Ber3 VPN and future vpn space
  ]
  priority = 2000
}

# temporary, allow ssh from 0.0.0.0/0
#   - TODO: figure out how to get traffic to transit via OpenVPN
#     nc -vz 34.134.254.175 22
#     // works
#
#     nc -b utun10 -vz 34.134.254.175 22
#     // fails

# resource "google_compute_firewall" "allow-ssh-from-all" {
#   name        = "default-allow-ssh-from-all"
#   network     = "default"
#   description = "TF_MANAGED"

#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }

#   source_ranges = ["0.0.0.0/0"]
#   priority      = 3000
# }

# aerickson
resource "google_compute_firewall" "allow-ssh-from-aerickson-home" {
  name        = "default-ssh-from-aerickson-home"
  network     = "default"
  description = "TF_MANAGED"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["136.25.89.230/32"]
  priority      = 4000
}
