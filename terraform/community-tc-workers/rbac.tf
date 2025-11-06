resource "google_project_iam_member" "project_owners" {
  for_each = toset(var.group_project_owners)

  project = local.project
  role    = "roles/owner"
  member  = "group:${each.value}"
}
