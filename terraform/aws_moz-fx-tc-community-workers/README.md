# AWS GitHub OIDC Configuration

This Terraform configuration sets up OpenID Connect (OIDC) authentication for GitHub Actions to AWS, allowing GitHub workflows to authenticate to AWS without storing long-lived credentials.

## Overview

This configuration creates:
- **GitHub OIDC Provider**: Establishes trust between AWS and GitHub Actions
- **IAM Role**: `GitHubActionsRole` that GitHub Actions workflows can assume
- **IAM Policy**: `GitHubActionsPackerPolicy` with permissions for Packer to build AMIs

## Configuration

### Variables

Edit `terraform.tfvars` to configure:

```hcl
oidc_github_repositories = ["mozilla-platform-ops/worker-images", "mozilla-platform-ops/monopacker"]
aws_region = "us-west-2"
```

- `oidc_github_repositories`: List of GitHub repositories (format: `owner/repo`) allowed to assume the IAM role
- `aws_region`: AWS region for resources (default: `us-west-2`)

## Usage

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Plan Changes

```bash
terraform plan
```

### 3. Apply Configuration

```bash
terraform apply
```

### 4. Use in GitHub Actions

After applying, use the output `github_actions_role_arn` in your GitHub Actions workflow:

```yaml
name: Build AMI with Packer

on:
  push:
    branches: [main]

permissions:
  id-token: write
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::885316786408:role/GitHubActionsRole
          aws-region: us-west-2

      - name: Run Packer
        run: packer build template.pkr.hcl
```

## Permissions

The `GitHubActionsPackerPolicy` grants the following EC2 permissions needed for Packer:
- Creating and managing EC2 instances
- Creating and managing AMIs
- Creating and managing security groups, volumes, and snapshots
- Managing keypairs and tags

## Security

- The OIDC provider only trusts workflows from repositories listed in `oidc_github_repositories`
- The IAM role can only be assumed by GitHub Actions workflows (via `sts:AssumeRoleWithWebIdentity`)
- The trust policy uses conditions to restrict which repositories can assume the role

## Outputs

- `github_actions_role_arn`: ARN of the IAM role to use in GitHub Actions workflows
- `github_oidc_provider_arn`: ARN of the GitHub OIDC provider

## Resources Created

- `aws_iam_openid_connect_provider.github_actions`: GitHub OIDC provider
- `aws_iam_role.github_actions`: IAM role for GitHub Actions
- `aws_iam_policy.github_actions_packer`: Policy with Packer permissions
- `aws_iam_role_policy_attachment.github_actions_packer`: Attaches policy to role

## Adding New Repositories

To allow additional repositories to use this OIDC configuration:

1. Add the repository to the `oidc_github_repositories` list in `terraform.tfvars`
2. Run `terraform apply` to update the trust policy

## References

- [GitHub Actions - Configuring OpenID Connect in AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [AWS IAM OIDC Identity Provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [Packer AWS Builder Permissions](https://developer.hashicorp.com/packer/plugins/builders/amazon#iam-task-or-instance-role)
