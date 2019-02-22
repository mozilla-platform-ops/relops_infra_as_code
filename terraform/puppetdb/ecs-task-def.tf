resource "aws_ecs_task_definition" "task_def" {
  family                   = "puppetdb"
  container_definitions    = "${file("task-definitions/puppetdb.json")}"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"

  tags = {
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "Prod"
    Owner       = "relops@mozilla.com"
  }
}
