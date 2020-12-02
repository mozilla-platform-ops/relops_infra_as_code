# This is a hosted zone delegated from mozops.net
# which is managed under the moz-devservices aws account
resource "aws_route53_zone" "relops_mozops_net_public" {
  name = "relops.mozops.net"
}

