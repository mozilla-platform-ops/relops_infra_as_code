variable "devloaner" {
  description = "developers using windows vms to test"
  type        = map(any)
  default = {
    "rg-west-us-devloaner" = {
      rgname     = "west-us-devloaner"
      rglocation = "westus"
    }
    "rg-north-central-devloaner" = {
      rgname     = "north-central-devloaner"
      rglocation = "northcentralus"
    }
    "rg-west-us-2-devloaner" = {
      rgname     = "west-us-2-devloaner"
      rglocation = "westus2"
    }
    "rg-west-us-3-devloaner" = {
      rgname     = "west-us-3-devloaner"
      rglocation = "westus3"
    }
    "rg-north-europe-devloaner" = {
      rgname     = "north-europe-devloaner"
      rglocation = "northeurope"
    }
  }
}