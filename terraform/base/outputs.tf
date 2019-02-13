# VPCs
output "vpc_us_east_1_id" {
  description = "The ID of the us-east-1 VPC"
  value       = "${module.vpc_moz_internal_us_east_1.vpc_id}"
}

output "vpc_us_west_2_id" {
  description = "The ID of the us-west-2 VPC"
  value       = "${module.vpc_moz_internal_us_west_2.vpc_id}"
}

output "us_east_1_public_subnets" {
  description = "List of IDs of us-east-1 public subnets"
  value       = ["${module.vpc_moz_internal_us_east_1.public_subnets}"]
}

output "us_west_2_public_subnets" {
  description = "List of IDs of us-west-2 public subnets"
  value       = ["${module.vpc_moz_internal_us_west_2.public_subnets}"]
}
