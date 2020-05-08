data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "regional_1" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.large"
  vpc_security_group_ids      = [aws_security_group.maas_ec2_sg.id]
  key_name                    = "relops_common"
  subnet_id                   = "subnet-0f7d7eedf80f0506b"
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 40
    delete_on_termination = true
  }

  tags = merge(
    local.common_tags,
    map(
      "Name", "maas-regional1.relops.mozops.net"
    )
  )
}

resource "aws_route53_record" "regional_1" {
  zone_id = data.aws_route53_zone.relops_mozops_net.zone_id
  name    = "maas-regional1.relops.mozops.net"
  type    = "A"
  ttl     = 300
  records = [aws_instance.regional_1.private_ip]
}

resource "aws_security_group" "maas_ec2_sg" {
  name        = "maas-regional-sg"
  description = "Allow maas traffic into ec2 instances"
  vpc_id      = join(", ", data.aws_vpcs.moz_internal_us_west_2.ids)

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = var.maas_ports["regional_api"]["begin"]
    to_port         = var.maas_ports["regional_api"]["end"]
    protocol        = var.maas_ports["regional_api"]["proto"]
    security_groups = [aws_security_group.maas_lb_sg.id]
    cidr_blocks     = ["10.49.0.0/16", "10.51.0.0/16"]
  }

  ingress {
    from_port   = var.maas_ports["regional_rpc"]["begin"]
    to_port     = var.maas_ports["regional_rpc"]["end"]
    protocol    = var.maas_ports["regional_rpc"]["proto"]
    cidr_blocks = ["10.49.0.0/16", "10.51.0.0/16"]
  }


  ingress {
    from_port   = 22
    to_port     = 22
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
      "Name", "maas-regional-sg"
    )
  )
}

