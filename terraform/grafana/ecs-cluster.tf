resource "aws_ecs_cluster" "main" {
  name = "grafana"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "grafana"
    )
  )}"
}

resource "aws_security_group" "ecs_public_sg" {
  name        = "ecs_grafana"
  description = "Allow grafana ecs inbound traffic"
  vpc_id      = "${data.aws_vpcs.moz_internal_us_west_2.ids[0]}"

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
  family                   = "grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = "${aws_iam_role.ecs-task-exec-role.arn}"
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image}",
    "memory": ${var.fargate_memory},
    "name": "grafana",
    "environment" : [
      { "name" : "GF_DATABASE_TYPE", "value" : "mysql" },
      { "name" : "GF_DATABASE_HOST", "value" : "${aws_db_instance.mysql.endpoint}" },
      { "name" : "GF_DATABASE_USER", "value" : "${var.db_username}" },
      { "name" : "GF_SERVER_DOMAIN", "value" : "${var.fqdn}" },
      { "name" : "GF_SERVER_ROOT_URL", "value" : "${var.root_url}" }
    ],
    "secrets": [
        {
            "name" : "GF_SECURITY_ADMIN_PASSWORD",
            "valueFrom" : "arn:aws:ssm:us-west-2:961225894672:parameter/grafana_admin_password"
        },
        {
            "name": "GF_DATABASE_PASSWORD",
            "valueFrom": "arn:aws:ssm:us-west-2:961225894672:parameter/grafana_db_password"
        }
    ],
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "main" {
  name            = "grafana"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.app.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["${data.aws_subnet_ids.public_subnets.ids}"]
    security_groups  = ["${aws_security_group.ecs_public_sg.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.lb_target_group.arn}"
    container_name   = "grafana"
    container_port   = 3000
  }

  depends_on = ["aws_lb_listener.front_end", "aws_ecs_task_definition.app"]
}
