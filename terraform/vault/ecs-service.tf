resource "aws_security_group" "ecs_vault_public_sg" {
  name        = "ecs_vault"
  description = "Allow vault ecs inbound traffic"
  vpc_id      = join(", ", data.aws_vpcs.moz_internal_us_west_2.ids)

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8200
    to_port         = 8200
    protocol        = "tcp"
    security_groups = ["${aws_security_group.vault_lb_sg.id}"]
  }

  ingress {
    from_port = 8201
    to_port   = 8201
    protocol  = "tcp"
    self      = true
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

resource "aws_ecs_service" "vault" {
  name                               = "vault"
  cluster                            = "${aws_ecs_cluster.vault.id}"
  task_definition                    = "${aws_ecs_task_definition.vault.arn}"
  scheduling_strategy                = "DAEMON"
  deployment_minimum_healthy_percent = 50

  network_configuration {
    subnets         = data.aws_subnet_ids.public_subnets.ids
    security_groups = ["${aws_security_group.ecs_vault_public_sg.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.vault_lb_target_group.arn}"
    container_name   = "vault"
    container_port   = 8200
  }
}
