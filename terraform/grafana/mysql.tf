resource "aws_security_group" "mysql_sg" {
  name        = "grafana-mysql-sg"
  description = "Allow inbound traffic into grafana mysql"
  vpc_id      = "${data.aws_vpcs.moz_internal_us_west_2.ids[0]}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ecs_public_sg.id}"]
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

resource "aws_db_subnet_group" "mysql" {
  name       = "grafana"
  subnet_ids = ["${data.aws_subnet_ids.public_subnets.ids}"]

  tags = {
    Name        = "grafana rds subnet group"
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "Prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_db_instance" "mysql" {
  identifier_prefix           = "grafana"
  allocated_storage           = 30
  allow_major_version_upgrade = "true"
  auto_minor_version_upgrade  = "true"
  apply_immediately           = "true"
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = "5.7.23"
  instance_class              = "db.t2.micro"
  skip_final_snapshot         = "true"
  name                        = "grafana"
  username                    = "${var.db_username}"

  # Password must be changed after provision
  password               = "XXXXXXXXXXXX"
  multi_az               = "true"
  db_subnet_group_name   = "${aws_db_subnet_group.mysql.id}"
  vpc_security_group_ids = ["${aws_security_group.mysql_sg.id}"]

  tags = {
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "Prod"
    Owner       = "relops@mozilla.com"
  }
}
