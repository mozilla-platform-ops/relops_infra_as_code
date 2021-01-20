resource "aws_kms_key" "sops_shamir_usw2_key" {
  provider                = aws.us-west-2
  description             = "Relops SOPS us-west-2 shamir key"
  deletion_window_in_days = 10

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(local.common_tags, {
  })
}

resource "aws_kms_alias" "sops_shamir_usw2_alias" {
  provider      = aws.us-west-2
  name          = "alias/relops_sops_usw2"
  target_key_id = aws_kms_key.sops_shamir_usw2_key.key_id

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_key" "sops_shamir_use1_key" {
  provider                = aws.us-east-1
  description             = "Relops SOPS us-east-1 shamir key"
  deletion_window_in_days = 10

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(local.common_tags, {
  })
}

resource "aws_kms_alias" "sops_shamir_use1_alias" {
  provider      = aws.us-east-1
  name          = "alias/relops_sops_use1"
  target_key_id = aws_kms_key.sops_shamir_use1_key.key_id

  lifecycle {
    prevent_destroy = true
  }
}

output "sops_shamir_usw2_key_arn" {
  value       = aws_kms_key.sops_shamir_usw2_key.arn
  description = "The us-west-2 SOPS shamir key ARN"
}

output "sops_shamir_use1_key_arn" {
  value       = aws_kms_key.sops_shamir_use1_key.arn
  description = "The us-east-1 SOPS shamir key ARN"
}

