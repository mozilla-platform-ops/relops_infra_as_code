resource "aws_ecs_cluster" "vault" {
  name = "vault"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "vault"
    })
  )
}

resource "aws_security_group" "ec2_vault_instance_sg" {
  name        = "ec2-vault-instance-sg"
  description = "Vault ec2 instances security group"
  vpc_id      = join(", ", data.aws_vpcs.moz_internal_us_west_2.ids)

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags,
    tomap({
      "Name" = "vault"
    })
  )
}

resource "aws_launch_template" "ecs-launch-template" {
  name          = "vault-launch-template"
  image_id      = var.ecs_ami
  instance_type = var.instance_type
  key_name      = "relops_common"
  user_data     = filebase64("userdata/ecs-userdata.sh")

  lifecycle {
    create_before_destroy = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs-instance-profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [aws_security_group.ec2_vault_instance_sg.id]
  }

  tags = merge(local.common_tags,
    tomap({
      "Name" = "vault-launch-template"
    })
  )
}

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                 = "ecs-vault-autoscaling-group"
  max_size             = var.max_instance_size
  min_size             = var.min_instance_size
  desired_capacity     = var.desired_capacity
  vpc_zone_identifier  = data.aws_subnet_ids.private_subnets.ids
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]

  launch_template {
    id      = aws_launch_template.ecs-launch-template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Vault-${var.tag_production_state}"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      instance_warmup        = 180
      min_healthy_percentage = 50
    }
  }
}
