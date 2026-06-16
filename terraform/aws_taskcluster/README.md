# AWS Taskcluster Worker Images and Worker Manager

This Terraform module configures the AWS account used by Taskcluster for
FirefoxCI AWS worker image builds and worker provisioning.

## Overview

This module creates:

- GitHub OIDC provider for GitHub Actions
- IAM role and policy for worker image Packer builds
- Existing IAM user and policy for FirefoxCI Taskcluster worker-manager AWS
  provisioning

The FirefoxCI worker-manager IAM principal already exists in this account as
`firefox-ci-taskcluster-worker-manager`. Import it before applying this module.
The imported user and policy are documented here without changing their access
key, policy document, or tags.

## Configuration

Edit `terraform.tfvars` for the target account, profile, allowed GitHub
repositories, and worker-manager IAM names if needed.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

The S3 backend configuration intentionally does not set a profile. Pass the
backend profile during init if your default AWS profile cannot read the shared
state bucket:

```bash
terraform init -backend-config=profile=<state-bucket-profile>
```

If the GitHub OIDC provider already exists, import it before applying:

```bash
terraform import aws_iam_openid_connect_provider.github_actions "arn:aws:iam::<account-id>:oidc-provider/token.actions.githubusercontent.com"
```

If the FirefoxCI worker-manager user and policy already exist, import them
before applying:

```bash
terraform import aws_iam_user.taskcluster_worker_manager firefox-ci-taskcluster-worker-manager
terraform import aws_iam_policy.taskcluster_worker_manager arn:aws:iam::<account-id>:policy/taskcluster-worker-manager
terraform import aws_iam_user_policy_attachment.taskcluster_worker_manager firefox-ci-taskcluster-worker-manager/arn:aws:iam::<account-id>:policy/taskcluster-worker-manager
```
