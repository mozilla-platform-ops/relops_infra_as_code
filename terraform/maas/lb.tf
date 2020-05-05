resource "aws_lb" "maas_regional" {
  name               = "maas-load-balancer"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.maas_lb_sg.id]
  subnets            = data.aws_subnet_ids.public_subnets.ids

  enable_deletion_protection = false
  tags = merge(
    local.common_tags,
    map(
      "Name", "maas-load-balancer"
    )
  )
}

resource "aws_security_group" "maas_lb_sg" {
  name        = "maas-lb-sg"
  description = "Allow maas https traffic into load balancer"
  vpc_id      = join(", ", data.aws_vpcs.moz_internal_us_west_2.ids)

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.49.0.0/16", "10.51.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    map(
      "Name", "maas-lb-sg"
    )
  )
}

resource "aws_lb_target_group" "maas_lb_target_group" {
  name        = "maas-lb-tg"
  port        = var.maas_ports["regional_api"]["begin"]
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = join(", ", data.aws_vpcs.moz_internal_us_west_2.ids)

  health_check {
    path                = "/MAAS/"
    port                = var.maas_ports["regional_api"]["begin"]
    healthy_threshold   = 2
    unhealthy_threshold = 10
    interval            = 60
    matcher             = "200"
  }
}

resource "aws_lb_listener" "maas_front_end" {
  load_balancer_arn = aws_lb.maas_regional.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate_validation.cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.maas_lb_target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "maas" {
  target_group_arn = aws_lb_target_group.maas_lb_target_group.arn
  target_id        = aws_instance.regional_1.private_ip
}

resource "aws_route53_record" "maas" {
  zone_id = data.aws_route53_zone.relops_mozops_net.zone_id
  name    = "maas.relops.mozops.net"
  type    = "A"

  alias {
    name                   = aws_lb.maas_regional.dns_name
    zone_id                = aws_lb.maas_regional.zone_id
    evaluate_target_health = true
  }
}
