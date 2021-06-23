resource "aws_vpn_gateway" "vpn_gw_use1" {
  provider = aws.us-east-1

  tags = {
    Name        = "USE1 VPN Gateway"
    Terraform   = "true"
    Repo_url    = var.repo_url
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

resource "aws_customer_gateway" "cgw_use1_mdc1" {
  provider   = aws.us-east-1
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

resource "aws_vpn_connection" "vpn_connection_use1_mdc1" {
  provider            = aws.us-east-1
  vpn_gateway_id      = aws_vpn_gateway.vpn_gw_use1.id
  customer_gateway_id = aws_customer_gateway.cgw_use1_mdc1.id
  type                = "ipsec.1"

  tags = {
    Name        = "USE1-MDC1"
    Terraform   = "true"
    Repo_url    = var.repo_url
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

data "aws_vpcs" "moz_internal_us_east_1" {
  provider = aws.us-east-1

  tags = {
    Name = "moz-internal-us-east-1"
  }
}

resource "aws_vpn_gateway_attachment" "vpn_attachment_use1" {
  provider       = aws.us-east-1
  vpc_id         = join(", ", data.aws_vpcs.moz_internal_us_east_1.ids)
  vpn_gateway_id = aws_vpn_gateway.vpn_gw_use1.id
}

data "aws_route_tables" "moz_internal_us_east_1" {
  provider = aws.us-east-1

  filter {
    name   = "tag:Name"
    values = ["moz-internal-us-east-1-*"]
  }
}

# Propagate vpn routes for each route table
resource "aws_vpn_gateway_route_propagation" "use1" {
  provider       = aws.us-east-1
  for_each       = data.aws_route_tables.moz_internal_us_east_1.ids
  route_table_id = each.key
  vpn_gateway_id = aws_vpn_gateway.vpn_gw_use1.id
}
