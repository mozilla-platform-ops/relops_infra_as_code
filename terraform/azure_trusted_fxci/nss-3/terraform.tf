terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "azure_fxci_nss_3.tfstate"
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

  # FXCI Trusted Azure dev/test Subscription
  subscription_id = "a30e97ab-734a-4f3b-a0e4-c51c0bff0701"
  tenant_id       = "c0dc8bb0-b616-427e-8217-9513964a145b"
}
