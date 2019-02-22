resource "aws_lb" "lb" {
  name               = "puppetdb-load-balancer"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.lb_sg.id}"]
  subnets            = ["${data.aws_subnet_ids.public_subnets.ids}"]

  enable_deletion_protection = false
}

resource "aws_security_group" "lb_sg" {
  name        = "puppetdb-lb-sg"
  description = "Allow puppet client traffic into load balancer"
  vpc_id      = "${data.aws_vpcs.moz_internal_us_west_2.ids[0]}"

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_lb_target_group" "lb_target_group" {
  name        = "puppetdb-lb-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${data.aws_vpcs.moz_internal_us_west_2.ids[0]}"

  health_check {
    path                = "/status/v1/services/puppetdb-status"
    port                = 8080
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_lb_listener" "firont_end" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "8080"
  protocol          = "HTTP"

  # TODO: Change listener to HTTPS
  #  ssl_policy        = "ELBSecurityPolicy-2016-08"
  #  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.lb_target_group.arn}"
  }
}
