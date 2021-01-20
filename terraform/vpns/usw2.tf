resource "aws_vpn_gateway" "vpn_gw_usw2" {
  provider = aws.us-west-2

  tags = {
    Name        = "USW1 VPN Gateway"
    Terraform   = "true"
    Repo_url    = var.repo_url
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_customer_gateway" "cgw_usw2_mdc1" {
  provider   = aws.us-west-2
  bgp_asn    = 65048
  ip_address = "63.245.208.251"
  type       = "ipsec.1"

  tags = {
    Name        = "MDC1 Customer Gateway"
    Terraform   = "true"
    Repo_url    = var.repo_url
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_customer_gateway" "cgw_usw2_mdc2" {
  provider   = aws.us-west-2
  bgp_asn    = 65050
  ip_address = "63.245.210.251"
  type       = "ipsec.1"

  tags = {
    Name        = "MDC2 Customer Gateway"
    Terraform   = "true"
    Repo_url    = var.repo_url
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_vpn_connection" "vpn_connection_usw2_mdc1" {
  provider            = aws.us-west-2
  vpn_gateway_id      = aws_vpn_gateway.vpn_gw_usw2.id
  customer_gateway_id = aws_customer_gateway.cgw_usw2_mdc1.id
  type                = "ipsec.1"

  tags = {
    Name        = "USW2-MDC1"
    Terraform   = "true"
    Repo_url    = var.repo_url
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_vpn_connection" "vpn_connection_usw2_mdc2" {
  provider            = aws.us-west-2
  vpn_gateway_id      = aws_vpn_gateway.vpn_gw_usw2.id
  customer_gateway_id = aws_customer_gateway.cgw_usw2_mdc2.id
  type                = "ipsec.1"

  tags = {
    Name        = "USW2-MDC2"
    Terraform   = "true"
    Repo_url    = var.repo_url
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

data "aws_vpcs" "moz_internal_us_west_2" {
  provider = aws.us-west-2

  tags = {
    Name = "moz-internal-us-west-2"
  }
}

resource "aws_vpn_gateway_attachment" "vpn_attachment_usw2" {
  provider       = aws.us-west-2
  vpc_id         = join(", ", data.aws_vpcs.moz_internal_us_west_2.ids)
  vpn_gateway_id = aws_vpn_gateway.vpn_gw_usw2.id
}

data "aws_route_tables" "moz_internal_us_west_2_public" {
  provider = aws.us-west-2

  tags = {
    Name = "moz-internal-us-west-2-public"
  }
}

resource "aws_vpn_gateway_route_propagation" "public_usw2" {
  provider       = aws.us-west-2
  route_table_id = join(", ", data.aws_route_tables.moz_internal_us_west_2_public.ids)
  vpn_gateway_id = aws_vpn_gateway.vpn_gw_usw2.id
}
