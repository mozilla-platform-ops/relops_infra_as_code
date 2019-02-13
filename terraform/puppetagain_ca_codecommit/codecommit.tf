resource "aws_codecommit_repository" "puppetagain_ca" {
  repository_name = "puppetagain_ca"
  description     = "Puppetagain Root Certificate Authority Inventory"
}

output "puppetagain_ca_clone_url_ssh" {
  value = "${aws_codecommit_repository.puppetagain_ca.clone_url_ssh}"
}
