terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "azure_fxci_enterprise-t.tfstate"
    use_lockfile   = true
    region         = "us-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["961225894672"]
  alias               = "us-west-2"
  region              = "us-west-2"
}

# Configure the Azure Provider
provider "azurerm" {
  features {}

  # FXCI Azure dev/test Subscription
  subscription_id = "108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"
  tenant_id       = "c0dc8bb0-b616-427e-8217-9513964a145b"
}
