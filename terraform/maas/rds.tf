resource "aws_db_subnet_group" "maas_db_subnet_group" {
  name        = "maas-dbgrp"
  description = "Maas DB subnet group"
  subnet_ids  = data.aws_subnet_ids.public_subnets.ids

  tags = merge(
    local.common_tags,
    map(
      "Name", "maas-dbgrp"
    )
  )
}

resource "aws_security_group" "maas_postgres_sg" {
  name        = "maas-postgres-sg"
  description = "Maas postgres security group"
  vpc_id      = join(", ", data.aws_vpcs.moz_internal_us_west_2.ids)

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.maas_ec2_sg.id]
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
      "Name", "maas-postgres-sg"
    )
  )
}


resource "aws_db_instance" "maas_postgres" {
  identifier                 = "maas-postgres"
  storage_type               = "gp2"
  allocated_storage          = 20
  engine                     = "postgres"
  instance_class             = "db.m4.large"
  maintenance_window         = "Sun:08:00-Sun:08:30"
  multi_az                   = false
  port                       = "5432"
  username                   = "postgres"
  password                   = "to_be_changed"
  publicly_accessible        = false
  auto_minor_version_upgrade = true
  skip_final_snapshot        = true
  db_subnet_group_name       = aws_db_subnet_group.maas_db_subnet_group.name
  vpc_security_group_ids     = [aws_security_group.maas_postgres_sg.id]

  tags = merge(
    local.common_tags,
    map(
      "Name", "maas-postgres"
    )
  )
}

output "maas_postgres" {
  value = {
    "address"  = aws_db_instance.maas_postgres.address
    "port"     = aws_db_instance.maas_postgres.port
    "username" = aws_db_instance.maas_postgres.username
  }
}
