resource "aws_ecs_cluster" "main" {
  name = "telegraf"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "telegraf"
    )
  )}"
}

resource "aws_security_group" "ecs_public_sg" {
  name        = "ecs_telegraf"
  description = "Allow telegraf ecs inbound traffic"
  vpc_id      = join(", ", data.aws_vpcs.moz_internal_us_west_2.ids)

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.lb_sg.id}"]
  }

  ingress {
    from_port       = "${var.webhook_port}"
    to_port         = "${var.webhook_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.lb_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "Prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "telegraf"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = "${aws_iam_role.ecs-task-exec-role.arn}"
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  depends_on               = ["aws_iam_role.ecs-task-exec-role"] # force recreate on change sha in definition

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image}",
    "memory": ${var.fargate_memory},
    "name": "telegraf",
    "environment" : [
      { "name" : "policy_sha1", "value" : "${sha1(file("ecs-task-exec-role.tf"))}" },
      { "name" : "INFLUXDB_URL", "value" : "${var.influxdb_url}" },
      { "name" : "INFLUXDB_USER", "value" : "${var.influxdb_user}" },
      { "name" : "INFLUXDB_DB", "value" : "${var.influxdb_db}" },
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
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      },
      {
        "containerPort": ${var.webhook_port},
        "hostPort": ${var.webhook_port}
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.telegraf.name}",
        "awslogs-region": "us-west-2",
        "awslogs-stream-prefix": "telegraf"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "main" {
  name = "telegraf"
  cluster = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.app.arn}"
  desired_count = "${var.app_count}"
  launch_type = "FARGATE"

  network_configuration {
    subnets = data.aws_subnet_ids.public_subnets.ids
    security_groups = ["${aws_security_group.ecs_public_sg.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.lb_target_group.arn}"
    container_name = "telegraf"
    container_port = 8086
  }

  depends_on = ["aws_lb_listener.front_end", "aws_ecs_task_definition.app"]
}
