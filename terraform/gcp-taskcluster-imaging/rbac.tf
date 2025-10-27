# Import blocks for existing IAM bindings
import {
  for_each = var.releng_users
  id       = "taskcluster-imaging roles/compute.imageUser user:${each.value}@mozilla.com"
  to       = google_project_iam_member.releng-users-image-user[each.key]
}

import {
  for_each = var.translations_users
  id       = "taskcluster-imaging roles/compute.imageUser user:${each.value}@mozilla.com"
  to       = google_project_iam_member.translations-users-image-user[each.key]
}

import {
  for_each = var.read_only_users
  id       = "taskcluster-imaging roles/compute.imageUser user:${each.value}@mozilla.com"
  to       = google_project_iam_member.read-only-users-image-user[each.key]
}

# Resource definitions
resource "google_project_iam_member" "releng-users-image-user" {
  for_each = var.releng_users

  member  = "user:${each.value}@mozilla.com"
  project = "taskcluster-imaging"
  role    = "roles/compute.imageUser"
}

resource "google_project_iam_member" "translations-users-image-user" {
  for_each = var.translations_users

  member  = "user:${each.value}@mozilla.com"
  project = "taskcluster-imaging"
  role    = "roles/compute.imageUser"
}

resource "google_project_iam_member" "read-only-users-image-user" {
  for_each = var.read_only_users

  member  = "user:${each.value}@mozilla.com"
  project = "taskcluster-imaging"
  role    = "roles/compute.imageUser"
}
