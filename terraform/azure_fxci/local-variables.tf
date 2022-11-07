variable "gecko1" {
  description = "storage account location"
  type        = map(any)
  default = {
    "rg-central-us-gecko-1" = {
      rgname     = "central-us-gecko-1"
      rglocation = "centralus"
    }
    "rg-east-us-gecko-1" = {
      rgname     = "east-us-gecko-1"
      rglocation = "eastus"
    }
    "rg-east-us-2-gecko-1" = {
      rgname     = "east-us-2-gecko-1"
      rglocation = "eastus2"
    }
    "rg-north-central-us-gecko-1" = {
      rgname     = "north-central-us-gecko-1"
      rglocation = "northcentralus"
    }
    "rg-south-central-us-gecko-1" = {
      rgname     = "south-central-us-gecko-1"
      rglocation = "southcentralus"
    }
    "rg-west-us-gecko-1" = {
      rgname     = "west-us-gecko-1"
      rglocation = "westus"
    }
  }
}

variable "gecko3" {
  description = "storage account location"
  type        = map(any)
  default = {
    "rg-central-us-gecko-3" = {
      rgname     = "central-us-gecko-3"
      rglocation = "centralus"
    }
    "rg-east-us-gecko-3" = {
      rgname     = "east-us-gecko-3"
      rglocation = "eastus"
    }
    "rg-east-us-2-gecko-3" = {
      rgname     = "east-us-2-gecko-3"
      rglocation = "eastus2"
    }
    "rg-north-central-us-gecko-3" = {
      rgname     = "north-central-us-gecko-3"
      rglocation = "northcentralus"
    }
    "rg-south-central-us-gecko-3" = {
      rgname     = "south-central-us-gecko-3"
      rglocation = "southcentralus"
    }
    "rg-west-us-gecko-3" = {
      rgname     = "west-us-gecko-3"
      rglocation = "westus"
    }
  }
}

variable "devloaner" {
  description = "developers using windows vms to test"
  type        = map(any)
  default = {
    "rg-west-us-devloaner" = {
      rgname     = "central-us-devloaner"
      rglocation = "centralus"
    }
  }
}
