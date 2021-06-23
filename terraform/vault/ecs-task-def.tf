resource "aws_ecs_task_definition" "vault" {
  family                   = "vault"
  container_definitions    = templatefile("task-definitions/vault.json", { docker_version = var.docker_version })
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs-task-role.arn

  tags = merge(local.common_tags,
    tomap({
      "Name" = "vault"
    })
  )
}
