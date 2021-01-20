resource "aws_ecs_task_definition" "vault" {
  family                   = "vault"
  container_definitions    = file("task-definitions/vault.json")
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs-task-role.arn

  tags = merge(local.common_tags,
    map(
      "Name", "vault"
    )
  )
}
