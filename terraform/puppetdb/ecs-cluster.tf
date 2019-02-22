resource "aws_ecs_cluster" "puppetdb" {
  name = "puppetdb"

  tags = {
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "Prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_security_group" "ec2_puppetdb_instance_sg" {
  name        = "ec2-puppetdb-instance-sg"
  description = "Allow ssh inbound traffic into puppetdb ec2 instances"
  vpc_id      = "${data.aws_vpcs.moz_internal_us_west_2.ids[0]}"

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TODO: remove ssh access to cluster ec2 instances
  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_launch_configuration" "ecs-launch-configuration" {
  name                 = "ecs-puppetdb-launch-configuration"
  image_id             = "${var.ecs_ami}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs-instance-profile.id}"

  lifecycle {
    create_before_destroy = true
  }

  security_groups             = ["${aws_security_group.ec2_puppetdb_instance_sg.id}"]
  associate_public_ip_address = "true"

  # TODO: remove single key and load mutiple keys via userdata
  key_name = "dividehex"

  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=puppetdb >> /etc/ecs/ecs.config
EOF
}

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                 = "ecs-puppetdb-autoscaling-group"
  max_size             = "${var.max_instance_size}"
  min_size             = "${var.min_instance_size}"
  desired_capacity     = "${var.desired_capacity}"
  vpc_zone_identifier  = ["${data.aws_subnet_ids.public_subnets.ids}"]
  launch_configuration = "${aws_launch_configuration.ecs-launch-configuration.name}"
  health_check_type    = "EC2"
}
