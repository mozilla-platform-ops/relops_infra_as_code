module "vpc_moz_internal_us_east_1" {
  source = "terraform-aws-modules/vpc/aws"

  providers = {
    aws = "aws.us-east-1"
  }

  name = "moz-internal-us-east-1"
  cidr = "10.191.6.0/24"

  azs            = ["us-east-1a", "us-east-1b"]
  public_subnets = ["10.191.6.0/25", "10.191.6.128/25"]

  public_subnet_tags = {
    Subnet_type = "public"
  }

  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = false

  tags = {
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "Prod"
    Owner       = "relops@mozilla.com"
  }
}

module "vpc_moz_internal_us_west_2" {
  source = "terraform-aws-modules/vpc/aws"

  providers = {
    aws = "aws.us-west-2"
  }

  name = "moz-internal-us-west-2"
  cidr = "10.191.7.0/24"

  azs            = ["us-west-2a", "us-west-2b"]
  public_subnets = ["10.191.7.0/25", "10.191.7.128/25"]

  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = false

  tags = {
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}
