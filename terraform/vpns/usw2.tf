resource "aws_vpn_gateway" "vpn_gw_usw2" {
  provider = "aws.us-west-2"

  tags = {
    Name        = "USW1 VPN Gateway"
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_customer_gateway" "cgw_usw2_mdc1" {
  provider   = "aws.us-west-2"
  bgp_asn    = 65048
  ip_address = "63.245.208.251"
  type       = "ipsec.1"

  tags = {
    Name        = "MDC1 Customer Gateway"
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_customer_gateway" "cgw_usw2_mdc2" {
  provider   = "aws.us-west-2"
  bgp_asn    = 65050
  ip_address = "63.245.210.251"
  type       = "ipsec.1"

  tags = {
    Name        = "MDC2 Customer Gateway"
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_customer_gateway" "cgw_usw2_macstadium_las_vegas" {
  provider   = "aws.us-west-2"
  bgp_asn    = 65000
  ip_address = "207.254.35.84"
  type       = "ipsec.1"

  tags = {
    Name        = "MacStadium Las Vegas Customer Gateway"
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_vpn_connection" "vpn_connection_usw2_mdc1" {
  provider            = "aws.us-west-2"
  vpn_gateway_id      = "${aws_vpn_gateway.vpn_gw_usw2.id}"
  customer_gateway_id = "${aws_customer_gateway.cgw_usw2_mdc1.id}"
  type                = "ipsec.1"

  tags = {
    Name        = "USW2-MDC1"
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_vpn_connection" "vpn_connection_usw2_mdc2" {
  provider            = "aws.us-west-2"
  vpn_gateway_id      = "${aws_vpn_gateway.vpn_gw_usw2.id}"
  customer_gateway_id = "${aws_customer_gateway.cgw_usw2_mdc2.id}"
  type                = "ipsec.1"

  tags = {
    Name        = "USW2-MDC2"
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_vpn_connection" "vpn_connection_usw2_macstadium_las_vegas" {
  provider            = "aws.us-west-2"
  vpn_gateway_id      = aws_vpn_gateway.vpn_gw_usw2.id
  customer_gateway_id = aws_customer_gateway.cgw_usw2_macstadium_las_vegas.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name        = "USW2-MACSTADIUM"
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_vpn_connection_route" "usw2_macstadium_las_vegas_route" {
  provider               = "aws.us-west-2"
  destination_cidr_block = "10.10.10.0/24"
  vpn_connection_id      = aws_vpn_connection.vpn_connection_usw2_macstadium_las_vegas.id
}

data "aws_vpcs" "moz_internal_us_west_2" {
  provider = "aws.us-west-2"

  tags = {
    Name = "moz-internal-us-west-2"
  }
}

resource "aws_vpn_gateway_attachment" "vpn_attachment_usw2" {
  provider       = "aws.us-west-2"
  vpc_id         = join(", ", data.aws_vpcs.moz_internal_us_west_2.ids)
  vpn_gateway_id = "${aws_vpn_gateway.vpn_gw_usw2.id}"
}

data "aws_route_tables" "moz_internal_us_west_2_public" {
  provider = "aws.us-west-2"

  tags = {
    Name = "moz-internal-us-west-2-public"
  }
}

resource "aws_vpn_gateway_route_propagation" "public_usw2" {
  provider       = "aws.us-west-2"
  route_table_id = join(", ", data.aws_route_tables.moz_internal_us_west_2_public.ids)
  vpn_gateway_id = "${aws_vpn_gateway.vpn_gw_usw2.id}"
}
