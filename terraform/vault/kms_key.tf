resource "aws_kms_key" "vault" {
  description             = "Vault unseal key"
  deletion_window_in_days = 10
}

data "aws_iam_policy_document" "vault-kms-unseal" {
  statement {
    sid       = "VaultKMSUnseal"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
  }
}

resource "aws_iam_policy" "vault-kms-unseal" {
  name   = "Vault-KMS-Unseal"
  policy = "${data.aws_iam_policy_document.vault-kms-unseal.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-instance-kms-role-attachment" {
  role       = "${aws_iam_role.ecs-task-role.name}"
  policy_arn = "${aws_iam_policy.vault-kms-unseal.arn}"
}
