# AWS RelOps Worker Images GitHub OIDC Configuration

This Terraform module configures GitHub Actions OIDC authentication in the
`relops-aws-prod` AWS account (`961225894672`) for worker image builds.

## Overview

This creates the same GitHub Actions/Packer authentication resources used by
the `aws_moz-fx-tc-community-workers` module, but in `relops-aws-prod`:

- GitHub OIDC provider for `https://token.actions.githubusercontent.com`
- `GitHubActionsRole` for GitHub Actions workflows
- `GitHubActionsPackerPolicy` with the EC2 permissions Packer needs to build AMIs

The default repository allowlist is:

```hcl
oidc_github_repositories = ["mozilla-platform-ops/worker-images", "mozilla-platform-ops/monopacker"]
```

## Usage

```bash
terraform init
terraform plan
terraform apply
```

After applying, worker-images can assume:

```text
arn:aws:iam::961225894672:role/GitHubActionsRole
```

If the GitHub OIDC provider already exists in `relops-aws-prod`, import it
before applying:

```bash
terraform import aws_iam_openid_connect_provider.github_actions arn:aws:iam::961225894672:oidc-provider/token.actions.githubusercontent.com
```

