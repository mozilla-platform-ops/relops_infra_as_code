resource "aws_vpc_endpoint" "kms" {
  vpc_id            = "${module.vpc_moz_internal_us_west_2.vpc_id}"
  service_name      = "com.amazonaws.us-west-2.kms"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    "${aws_security_group.kms_sg.id}",
  ]

  subnet_ids = ["${module.vpc_moz_internal_us_west_2.public_subnets}"]

  private_dns_enabled = true
}

resource "aws_security_group" "kms_sg" {
  name        = "kms-sg"
  description = "Allow traffic to kms endpoint"
  vpc_id      = "${module.vpc_moz_internal_us_west_2.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.191.7.0/24"]
  }

  tags = {
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "Prod"
    Owner       = "relops@mozilla.com"
  }
}
