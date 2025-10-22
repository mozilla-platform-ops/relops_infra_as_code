provider "google" {
  project = local.project
  # not sure what these should be
  region  = "us-west1"
  zone    = "us-west1-b"
}
