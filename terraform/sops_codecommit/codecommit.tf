resource "aws_codecommit_repository" "sop" {
  repository_name = "sops"
  description     = "Relops SOPS secrets store"

  tags = merge(local.common_tags, {
  })
}

output "sops_clone_url_ssh" {
  value = "${aws_codecommit_repository.sop.clone_url_ssh}"
}
