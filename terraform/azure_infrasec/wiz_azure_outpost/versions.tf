terraform {
  required_version = ">= 0.13.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.83"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.46"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.10"
    }
  }
}