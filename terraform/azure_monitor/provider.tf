terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.114" }
    random  = { source = "hashicorp/random", version = "~> 3.6" }
    time    = { source = "hashicorp/time", version = "~> 0.10" }
  }
}

locals {
  monitor_subscription = "36c94cc5-8e6d-49db-a034-bb82b6a2632e"
  mozilla_tenant_id    = "c0dc8bb0-b616-427e-8217-9513964a145b"
}

provider "azurerm" {
  features {}
  subscription_id = local.monitor_subscription
  tenant_id       = local.mozilla_tenant_id
}