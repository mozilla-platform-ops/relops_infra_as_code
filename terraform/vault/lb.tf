resource "aws_lb" "vault" {
  name               = "vault-load-balancer"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.vault_lb_sg.id]
  subnets            = data.aws_subnet_ids.public_subnets.ids

  enable_deletion_protection = false
}

resource "aws_security_group" "vault_lb_sg" {
  name        = "vault-lb-sg"
  description = "Allow vault client traffic into load balancer"
  vpc_id      = join(", ", data.aws_vpcs.moz_internal_us_west_2.ids)

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["10.49.0.0/16", "10.51.0.0/16"]
  }

  tags = {
    Terraform   = "true"
    Repo_url    = var.repo_url
    Environment = "Prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_lb_target_group" "vault_lb_target_group" {
  name        = "vault-lb-tg"
  port        = 8200
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = join(", ", data.aws_vpcs.moz_internal_us_west_2.ids)

  health_check {
    path                = "/v1/sys/health"
    port                = 8200
    healthy_threshold   = 2
    unhealthy_threshold = 10
    interval            = 60
    matcher             = "200,429,472,473"
  }
}

resource "aws_lb_listener" "vault_firont_end" {
  load_balancer_arn = aws_lb.vault.arn
  port              = "8200"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate_validation.cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault_lb_target_group.arn
  }
}

resource "aws_route53_record" "vault" {
  zone_id = data.aws_route53_zone.relops_mozops_net.zone_id
  name    = "vault.relops.mozops.net"
  type    = "A"

  alias {
    name                   = aws_lb.vault.dns_name
    zone_id                = aws_lb.vault.zone_id
    evaluate_target_health = true
  }
}
