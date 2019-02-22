resource "aws_security_group" "postgres_sg" {
  name        = "puppetdb-postgres-sg"
  description = "Allow inbound traffic into puppetdb postgres"
  vpc_id      = "${data.aws_vpcs.moz_internal_us_west_2.ids[0]}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    #    security_groups = ["${aws_security_group.ecs_public_sg.id}"]
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

resource "aws_db_subnet_group" "postgres" {
  name       = "puppetdb"
  subnet_ids = ["${data.aws_subnet_ids.public_subnets.ids}"]

  tags = {
    Name        = "Puppetdb postgres subnet group"
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "Prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage           = 30
  allow_major_version_upgrade = "true"
  auto_minor_version_upgrade  = "true"
  apply_immediately           = "true"
  storage_type                = "gp2"
  engine                      = "postgres"
  engine_version              = "10.6"
  instance_class              = "db.t2.micro"
  name                        = "puppetdb"
  username                    = "puppetdb"

  # Password is changed post deployment
  password               = "puppetdb"
  multi_az               = "true"
  db_subnet_group_name   = "${aws_db_subnet_group.postgres.id}"
  vpc_security_group_ids = ["${aws_security_group.postgres_sg.id}"]

  tags = {
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "Prod"
    Owner       = "relops@mozilla.com"
  }
}
