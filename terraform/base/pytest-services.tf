# Pytest Service allows auditing from Firefox Security
# https://bugzilla.mozilla.org/show_bug.cgi?id=1527492

data "aws_iam_policy_document" "pytest_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::361527076523:root"]
    }
  }
}

resource "aws_iam_role_policy" "pytest_role_policy" {
  name   = "PytestServices"
  role   = aws_iam_role.pytest_role.id
  policy = file("policies/PytestServicesReadOnly.json")
}

resource "aws_iam_role" "pytest_role" {
  name               = "PytestServices"
  assume_role_policy = data.aws_iam_policy_document.pytest_assume_role_policy.json
}

