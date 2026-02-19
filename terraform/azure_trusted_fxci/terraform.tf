terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
  }
}
