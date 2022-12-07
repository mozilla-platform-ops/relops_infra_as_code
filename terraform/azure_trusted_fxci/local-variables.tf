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

variable "comm3" {
  description = "storage account location"
  type        = map(any)
  default = {
    "rg-central-us-comm-3" = {
      rgname     = "central-us-comm-3"
      rglocation = "centralus"
    }
    "rg-east-us-comm-3" = {
      rgname     = "east-us-comm-3"
      rglocation = "eastus"
    }
    "rg-east-us-2-comm-3" = {
      rgname     = "east-us-2-comm-3"
      rglocation = "eastus2"
    }
    "rg-north-central-us-comm-3" = {
      rgname     = "north-central-us-comm-3"
      rglocation = "northcentralus"
    }
    "rg-south-central-us-comm-3" = {
      rgname     = "south-central-us-comm-3"
      rglocation = "southcentralus"
    }
    "rg-west-us-comm-3" = {
      rgname     = "west-us-comm-3"
      rglocation = "westus"
    }
  }
}

variable "vpn3" {
  description = "storage account location"
  type        = map(any)
  default = {
    "rg-central-us-vpn-3" = {
      rgname     = "central-us-vpn-3"
      rglocation = "centralus"
    }
    "rg-east-us-vpn-3" = {
      rgname     = "east-us-vpn-3"
      rglocation = "eastus"
    }
    "rg-east-us-2-vpn-3" = {
      rgname     = "east-us-2-vpn-3"
      rglocation = "eastus2"
    }
    "rg-north-central-us-vpn-3" = {
      rgname     = "north-central-us-vpn-3"
      rglocation = "northcentralus"
    }
    "rg-south-central-us-vpn-3" = {
      rgname     = "south-central-us-vpn-3"
      rglocation = "southcentralus"
    }
    "rg-west-us-vpn-3" = {
      rgname     = "west-us-vpn-3"
      rglocation = "westus"
    }
  }
}

variable "nss3" {
  description = "storage account location"
  type        = map(any)
  default = {
    "rg-central-us-nss-3" = {
      rgname     = "central-us-nss-3"
      rglocation = "centralus"
    }
    "rg-east-us-nss-3" = {
      rgname     = "east-us-nss-3"
      rglocation = "eastus"
    }
    "rg-east-us-2-nss-3" = {
      rgname     = "east-us-2-nss-3"
      rglocation = "eastus2"
    }
    "rg-north-central-us-nss-3" = {
      rgname     = "north-central-us-nss-3"
      rglocation = "northcentralus"
    }
    "rg-south-central-us-nss-3" = {
      rgname     = "south-central-us-nss-3"
      rglocation = "southcentralus"
    }
    "rg-west-us-nss-3" = {
      rgname     = "west-us-nss-3"
      rglocation = "westus"
    }
  }
}
