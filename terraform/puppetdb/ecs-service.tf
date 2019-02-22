resource "aws_security_group" "ecs_public_sg" {
  name        = "ecs_puppet"
  description = "Allow ecs inbound traffic"
  vpc_id      = "${data.aws_vpcs.moz_internal_us_west_2.ids[0]}"

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
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

resource "aws_ecs_service" "ecs_service" {
  name                = "puppetdb"
  cluster             = "${aws_ecs_cluster.puppetdb.id}"
  task_definition     = "${aws_ecs_task_definition.task_def.arn}"
  scheduling_strategy = "DAEMON"

  network_configuration {
    subnets         = ["${data.aws_subnet_ids.public_subnets.ids}"]
    security_groups = ["${aws_security_group.ecs_public_sg.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.lb_target_group.arn}"
    container_name   = "puppetdb"
    container_port   = 8080
  }
}
