# Look up usw2 vpc
data "aws_vpcs" "moz_internal_us_west_2" {
  provider = "aws.us-west-2"

  tags = {
    Name = "moz-internal-us-west-2"
  }
}

# Lookup public subnets of usw2 vpc
data "aws_subnet_ids" "public_subnets" {
  vpc_id = "${data.aws_vpcs.moz_internal_us_west_2.ids[0]}"

  tags = {
    Subnet_type = "public"
  }
}

data "aws_route53_zone" "relops_mozops_net" {
  name = "relops.mozops.net."
}
