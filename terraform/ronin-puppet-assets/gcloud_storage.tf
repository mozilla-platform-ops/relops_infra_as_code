# linux (and android)

resource "google_storage_default_object_access_control" "linux_public_rule" {
  bucket = google_storage_bucket.linux_bucket.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket" "linux_bucket" {
  name          = "ronin-puppet-linux-assets"
  location      = "US-WEST1"
  storage_class = "STANDARD" # default value
}

# mac: TBD