resource "aws_ecs_cluster" "vault" {
  name = "vault"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "vault"
    )
  )}"
}

resource "aws_security_group" "ec2_vault_instance_sg" {
  name        = "ec2-vault-instance-sg"
  description = "Vault ec2 instances security group"
  vpc_id      = join(", ", data.aws_vpcs.moz_internal_us_west_2.ids)

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
  name_prefix          = "ecs-vault-launch-configuration-"
  image_id             = "${var.ecs_ami}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs-instance-profile.id}"

  lifecycle {
    create_before_destroy = true
  }

  security_groups             = ["${aws_security_group.ec2_vault_instance_sg.id}"]
  associate_public_ip_address = "true"

  key_name = "relops_common"

  user_data = "${file("userdata/ecs-userdata.sh")}"
}

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                 = "ecs-vault-autoscaling-group"
  max_size             = "${var.max_instance_size}"
  min_size             = "${var.min_instance_size}"
  desired_capacity     = "${var.desired_capacity}"
  vpc_zone_identifier  = data.aws_subnet_ids.public_subnets.ids
  launch_configuration = "${aws_launch_configuration.ecs-launch-configuration.name}"
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]
}
