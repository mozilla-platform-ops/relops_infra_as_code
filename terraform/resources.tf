locals {
  # common_tags should be included in all resources
  common_tags = {
    # Always true; it's why we're here
    terraform        = "true"
    project_name     = "${var.tag_project_name}"
    production_state = "${var.tag_production_state}"
    owner_email      = "${var.tag_owner_email}"
    source_repo_url  = "https://github.com/mozilla-platform-ops/relops_infra_as_code"
  }
}
