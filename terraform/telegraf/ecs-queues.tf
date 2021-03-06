resource "aws_ecs_service" "main_queues" {
  name            = "telegraf_queues"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app_queues.arn
  desired_count   = var.queue_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnet_ids.public_subnets.ids
    security_groups  = [aws_security_group.ecs_public_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.app_queues]
}

resource "aws_ecs_task_definition" "app_queues" {
  family                   = "telegraf"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs-task-exec-role.arn
  cpu                      = var.queue_cpu
  memory                   = var.queue_memory
  depends_on               = [aws_iam_role.ecs-task-exec-role] # force recreate on change sha in definition

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.queue_cpu},
    "image": "${var.queue_image}",
    "memory": ${var.queue_memory},
    "name": "telegraf",
    "environment" : [
      { "name" : "policy_sha1", "value" : "${sha1(file("ecs-task-exec-role.tf"))}" },
      { "name" : "INFLUXDB_URL", "value" : "${var.influxdb_url}" },
      { "name" : "INFLUXDB_USER", "value" : "${var.influxdb_user}" },
      { "name" : "INFLUXDB_DB", "value" : "${var.influxdb_db}" },
      { "name" : "TELEGRAF_CONFIG", "value" : "telegraf_queues.conf" },
      { "name" : "INTERVAL", "value" : "${var.interval}" },
      { "name" : "MEDIUM_INTERVAL", "value" : "${var.medium_interval}" },
      { "name" : "LONG_INTERVAL", "value" : "${var.long_interval}" }
    ],
    "secrets": [
        {
            "name": "INFLUXDB_PASSWORD",
            "valueFrom": "arn:aws:ssm:us-west-2:961225894672:parameter/influxdb_wo_password"
        }
    ],
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.telegraf.name}",
        "awslogs-region": "us-west-2",
        "awslogs-stream-prefix": "telegraf_queues"
      }
    }
  }
]
DEFINITION
}
