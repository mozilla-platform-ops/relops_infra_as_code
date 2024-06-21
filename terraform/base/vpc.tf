module "vpc_moz_internal_us_east_1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"

  providers = {
    aws = aws.us-east-1
  }

  name = "moz-internal-us-east-1"
  cidr = "10.191.6.0/24"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.191.6.0/26", "10.191.6.64/26"]
  private_subnets = ["10.191.6.128/26", "10.191.6.192/26"]

  public_subnet_tags = {
    Subnet_type = "public"
  }

  private_subnet_tags = {
    Subnet_type = "private"
  }

  enable_dhcp_options      = true
  dhcp_options_domain_name = "use1.relops"
  enable_dns_hostnames     = true
  enable_dns_support       = true
  map_public_ip_on_launch  = false
  enable_nat_gateway       = true

  tags = {
    Terraform   = "true"
    Repo_url    = var.repo_url
    Environment = "Prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_route53_zone" "use1" {
  name = "use1.relops"

  vpc {
    vpc_id     = module.vpc_moz_internal_us_east_1.vpc_id
    vpc_region = "us-east-1"
  }
}

resource "aws_route53_zone" "use1_arpa" {
  name = "6.191.10.in-addr.arpa."

  vpc {
    vpc_id     = module.vpc_moz_internal_us_east_1.vpc_id
    vpc_region = "us-east-1"
  }
}

module "vpc_moz_internal_us_west_2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"

  providers = {
    aws = aws.us-west-2
  }

  name = "moz-internal-us-west-2"
  cidr = "10.191.7.0/24"

  azs             = ["us-west-2a", "us-west-2b"]
  public_subnets  = ["10.191.7.0/26", "10.191.7.64/26"]
  private_subnets = ["10.191.7.128/26", "10.191.7.192/26"]

  public_subnet_tags = {
    Subnet_type = "public"
  }

  private_subnet_tags = {
    Subnet_type = "private"
  }

  enable_dhcp_options      = true
  dhcp_options_domain_name = "usw2.relops"
  enable_dns_hostnames     = true
  enable_dns_support       = true
  map_public_ip_on_launch  = false
  enable_nat_gateway       = true

  enable_dynamodb_endpoint = true

  tags = {
    Terraform   = "true"
    Repo_url    = var.repo_url
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_route53_zone" "usw2" {
  name = "usw2.relops"

  vpc {
    vpc_id     = module.vpc_moz_internal_us_west_2.vpc_id
    vpc_region = "us-west-2"
  }
}

resource "aws_route53_zone" "usw2_arpa" {
  name = "7.191.10.in-addr.arpa."

  vpc {
    vpc_id     = module.vpc_moz_internal_us_west_2.vpc_id
    vpc_region = "us-west-2"
  }
}

