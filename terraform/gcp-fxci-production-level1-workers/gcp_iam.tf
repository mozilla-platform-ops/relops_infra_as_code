variable "releng_users" {
    type = set(string)
    description = "list of usernames"
}

variable "translations_users" {
    type = set(string)
    description = "list of usernames"
}

resource "google_project_iam_member" "releng-users" {
    for_each = "${var.releng_users}"

  project = "fxci-production-level1-workers"
  role    = "compute.instances.list"
  member  = "user:${each.value}@mozilla.com"
}

resource "google_project_iam_member" "translations-users" {
    for_each = "${var.releng_users}"

  project = "fxci-production-level1-workers"
  role    = "compute.instances.list"
  member  = "user:${each.value}@mozilla.com"
}