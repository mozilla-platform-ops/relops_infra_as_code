# RelOps Infrastructure-As-Code
[![CircleCI Status](https://circleci.com/gh/mozilla-platform-ops/relops_infra_as_code.svg?style=svg)](https://app.circleci.com/pipelines/github/mozilla-platform-ops/relops_infra_as_code)

## getting started

The repo uses `pre-commit` (https://pre-commit.com/) to install and manage git
pre-commit hooks.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

### os x

```bash
# newer modules, use latest tf (1.13.4+)
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# for working with older modules, use tf 1.5.7
brew install terraform

# install dev dependencies
brew install pre-commit
brew install terraform-docs

# setup pre-commit
pre-commit install
```

## structure

We manage state per-module. This allows us to work with some isolation to avoid
conflicts with other people's changes and reduces the number of objects synced
during `terraform apply`.

### creating new modules

```
cd terraform
./create_state.sh "descriptive_name_for_what_this_module_does"
```

Then follow the directions given.

## Authenticating to Azure, Google Cloud, or AWS

```Bash
## AWS
export AWS_ACCESS_KEY_ID=foo
export AWS_SECRET_ACCESS_KEY=bar

## GCP
export GOOGLE_CLOUD_KEYFILE_JSON=~/.config/gcloud/application_default_credentials.json

## Azure
$ az login
$ az account set --subscription "108d46d5-fe9b-4850-9a7d-8c914aa6c1f0" ## based on subscription
```

## Updating providers

Providers should be regularly upgraded. If you get an error during a plan or apply, always try this first.

```bash
terraform init -upgrade
```
