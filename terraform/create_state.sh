#!/bin/bash

# TODO: provide warning when `tf apply`ing in base, that user should exit if it's going to delete anything
# TODO: provide user with a `tf apply -target` command that will avoid the risk of deletions

function usage ()
{
    echo Usage:
    echo ./create_state name
}

if [ -z "${1}" ]; then
    usage
    exit 1
fi

STATE_NAME=$1

if [ -a "${STATE_NAME}" ]; then
    echo "Error: A file or dir by that name already exists"
    exit 1
fi

if [ -a "base/tf_state_lock_${STATE_NAME}.tf" ]; then
    echo "Error: A tf state lock file of that name already exists"
    exit 1
fi


echo "Creating dir: ${STATE_NAME}"
mkdir -p "${STATE_NAME}"
echo "Creating variables.tf link"
ln -s ../variables.tf "${STATE_NAME}/variables.tf"
echo "Creating providers.tf link"
ln -s ../providers.tf "${STATE_NAME}/providers.tf"
echo "Creating resources.tf link"
ln -s ../resources.tf "${STATE_NAME}/resources.tf"

echo "Generating ${STATE_NAME}/backend.tf"
cat <<EOF >"${STATE_NAME}/backend.tf"
terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "${STATE_NAME}.tfstate"
    dynamodb_table = "tf_state_lock_${STATE_NAME}"
    region         = "us-west-2"
  }
}
EOF

echo "Generating base/tf_state_lock_${STATE_NAME}.tf"
cat <<EOF >"base/tf_state_lock_${STATE_NAME}.tf"
resource "aws_dynamodb_table" "tf_state_lock_${STATE_NAME}" {
  name           = "tf_state_lock_${STATE_NAME}"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Name        = "${STATE_NAME} Terraform State Lock Table"
    Terraform   = "true"
    Repo_url    = "\${var.repo_url}"
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}
EOF

echo "Please run 'terraform apply' in base to create state lock dynamodb"
echo "Then run 'terraform init' and 'terraform apply' in ${STATE_NAME} to initialize the environment"

exit 0
