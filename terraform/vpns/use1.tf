resource "aws_vpn_gateway" "vpn_gw_use1" {
  provider = "aws.us-east-1"

  tags = {
    Name        = "USE1 VPN Gateway"
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_customer_gateway" "cgw_use1_mdc1" {
  provider   = "aws.us-east-1"
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

resource "aws_customer_gateway" "cgw_use1_mdc2" {
  provider   = "aws.us-east-1"
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

resource "aws_customer_gateway" "cgw_use1_macstadium_las_vegas" {
  provider   = "aws.us-east-1"
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


resource "aws_vpn_connection" "vpn_connection_use1_mdc1" {
  provider            = "aws.us-east-1"
  vpn_gateway_id      = "${aws_vpn_gateway.vpn_gw_use1.id}"
  customer_gateway_id = "${aws_customer_gateway.cgw_use1_mdc1.id}"
  type                = "ipsec.1"

  tags = {
    Name        = "USE1-MDC1"
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_vpn_connection" "vpn_connection_use1_mdc2" {
  provider            = "aws.us-east-1"
  vpn_gateway_id      = "${aws_vpn_gateway.vpn_gw_use1.id}"
  customer_gateway_id = "${aws_customer_gateway.cgw_use1_mdc2.id}"
  type                = "ipsec.1"

  tags = {
    Name        = "USE1-MDC2"
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_vpn_connection" "vpn_connection_use1_macstadium_las_vegas" {
  provider            = "aws.us-east-1"
  vpn_gateway_id      = aws_vpn_gateway.vpn_gw_use1.id
  customer_gateway_id = aws_customer_gateway.cgw_use1_macstadium_las_vegas.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name        = "USE1-MACSTADIUM"
    Terraform   = "true"
    Repo_url    = "${var.repo_url}"
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_vpn_connection_route" "use1_macstadium_las_vegas_route" {
  provider               = "aws.us-east-1"
  destination_cidr_block = "10.10.10.0/24"
  vpn_connection_id      = aws_vpn_connection.vpn_connection_use1_macstadium_las_vegas.id
}

data "aws_vpcs" "moz_internal_us_east_1" {
  provider = "aws.us-east-1"

  tags = {
    Name = "moz-internal-us-east-1"
  }
}

resource "aws_vpn_gateway_attachment" "vpn_attachment_use1" {
  provider       = "aws.us-east-1"
  vpc_id         = join(", ", data.aws_vpcs.moz_internal_us_east_1.ids)
  vpn_gateway_id = "${aws_vpn_gateway.vpn_gw_use1.id}"
}

data "aws_route_tables" "moz_internal_us_east_1_public" {
  provider = "aws.us-east-1"

  tags = {
    Name = "moz-internal-us-east-1-public"
  }
}

resource "aws_vpn_gateway_route_propagation" "public_use1" {
  provider       = "aws.us-east-1"
  route_table_id = join(", ", data.aws_route_tables.moz_internal_us_east_1_public.ids)
  vpn_gateway_id = "${aws_vpn_gateway.vpn_gw_use1.id}"
}
