# RelOps Infrastructure-As-Code
[![Build Status](https://travis-ci.com/mozilla-platform-ops/relops_infra_as_code.svg?branch=master)](https://travis-ci.com/mozilla-platform-ops/relops_infra_as_code)

## getting started

The repo uses `pre-commit` (https://pre-commit.com/) to install and manage git
pre-commit hooks.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

### os x

```
brew install pre-commit
brew install terraform-docs

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
