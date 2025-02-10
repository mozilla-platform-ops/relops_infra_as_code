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
    "rg-west-us-2-gecko-1" = {
      rgname     = "west-us-2-gecko-1"
      rglocation = "westus2"
    }
    "rg-west-us-3-gecko-1" = {
      rgname     = "west-us-3-gecko-1"
      rglocation = "westus3"
    }
  }
}

variable "gecko2" {
  description = "storage account location"
  type        = map(any)
  default = {
    "rg-central-us-gecko-2" = {
      rgname     = "central-us-gecko-2"
      rglocation = "centralus"
    }
    "rg-east-us-gecko-2" = {
      rgname     = "east-us-gecko-2"
      rglocation = "eastus"
    }
    "rg-east-us-2-gecko-2" = {
      rgname     = "east-us-2-gecko-2"
      rglocation = "eastus2"
    }
    "rg-north-central-us-gecko-2" = {
      rgname     = "north-central-us-gecko-2"
      rglocation = "northcentralus"
    }
    "rg-south-central-us-gecko-2" = {
      rgname     = "south-central-us-gecko-2"
      rglocation = "southcentralus"
    }
    "rg-west-us-gecko-2" = {
      rgname     = "west-us-gecko-2"
      rglocation = "westus"
    }
    "rg-west-us-2-gecko-2" = {
      rgname     = "west-us-2-gecko-2"
      rglocation = "westus2"
    }
  }
}

variable "comm1" {
  description = "storage account location"
  type        = map(any)
  default = {
    "rg-central-us-comm-1" = {
      rgname     = "central-us-comm-1"
      rglocation = "centralus"
    }
    "rg-east-us-comm-1" = {
      rgname     = "east-us-comm-1"
      rglocation = "eastus"
    }
    "rg-east-us-2-comm-1" = {
      rgname     = "east-us-2-comm-1"
      rglocation = "eastus2"
    }
    "rg-north-central-us-comm-1" = {
      rgname     = "north-central-us-comm-1"
      rglocation = "northcentralus"
    }
    "rg-south-central-us-comm-1" = {
      rgname     = "south-central-us-comm-1"
      rglocation = "southcentralus"
    }
    "rg-west-us-comm-1" = {
      rgname     = "west-us-comm-1"
      rglocation = "westus"
    }
    "rg-west-us-2-comm-1" = {
      rgname     = "west-us-2-comm-1"
      rglocation = "westus2"
    }
  }
}

variable "comm2" {
  description = "storage account location"
  type        = map(any)
  default = {
    "rg-central-us-comm-2" = {
      rgname     = "central-us-comm-2"
      rglocation = "centralus"
    }
    "rg-east-us-comm-2" = {
      rgname     = "east-us-comm-2"
      rglocation = "eastus"
    }
    "rg-east-us-2-comm-2" = {
      rgname     = "east-us-2-comm-2"
      rglocation = "eastus2"
    }
    "rg-north-central-us-comm-2" = {
      rgname     = "north-central-us-comm-2"
      rglocation = "northcentralus"
    }
    "rg-south-central-us-comm-2" = {
      rgname     = "south-central-us-comm-2"
      rglocation = "southcentralus"
    }
    "rg-west-us-comm-2" = {
      rgname     = "west-us-comm-2"
      rglocation = "westus"
    }
    "rg-west-us-2-comm-2" = {
      rgname     = "west-us-2-comm-2"
      rglocation = "westus2"
    }
  }
}

variable "vpn1" {
  description = "storage account location"
  type        = map(any)
  default = {
    "rg-central-us-vpn-1" = {
      rgname     = "central-us-vpn-1"
      rglocation = "centralus"
    }
    "rg-east-us-vpn-1" = {
      rgname     = "east-us-vpn-1"
      rglocation = "eastus"
    }
    "rg-east-us-2-vpn-1" = {
      rgname     = "east-us-2-vpn-1"
      rglocation = "eastus2"
    }
    "rg-north-central-us-vpn-1" = {
      rgname     = "north-central-us-vpn-1"
      rglocation = "northcentralus"
    }
    "rg-south-central-us-vpn-1" = {
      rgname     = "south-central-us-vpn-1"
      rglocation = "southcentralus"
    }
    "rg-west-us-vpn-1" = {
      rgname     = "west-us-vpn-1"
      rglocation = "westus"
    }
    "rg-west-us-2-vpn-1" = {
      rgname     = "west-us-2-vpn-1"
      rglocation = "westus2"
    }
  }
}

variable "nss1" {
  description = "storage account location"
  type        = map(any)
  default = {
    "rg-central-us-nss-1" = {
      rgname     = "central-us-nss-1"
      rglocation = "centralus"
    }
    "rg-east-us-nss-1" = {
      rgname     = "east-us-nss-1"
      rglocation = "eastus"
    }
    "rg-east-us-2-nss-1" = {
      rgname     = "east-us-2-nss-1"
      rglocation = "eastus2"
    }
    "rg-north-central-us-nss-1" = {
      rgname     = "north-central-us-nss-1"
      rglocation = "northcentralus"
    }
    "rg-south-central-us-nss-1" = {
      rgname     = "south-central-us-nss-1"
      rglocation = "southcentralus"
    }
    "rg-west-us-nss-1" = {
      rgname     = "west-us-nss-1"
      rglocation = "westus"
    }
    "rg-west-us-2-nss-1" = {
      rgname     = "west-us-2-nss-1"
      rglocation = "westus2"
    }
  }
}

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

variable "geckot" {
  description = "geckot taskcluster azure resources"
  type        = map(any)
  default = {
    "rg-uk-south-gecko-t" = {
      rgname     = "uk-south-gecko-t"
      rglocation = "uksouth"
    }
    "rg-uk-west-gecko-t" = {
      rgname     = "uk-west-gecko-t"
      rglocation = "ukwest"
    }
  }
}

variable "mozilla1" {
  description = "mozilla-1 pool group taskcluster azure resources"
  type        = map(any)
  default = {
    "rg-central-us-mozilla-1" = {
      rgname     = "central-us-mozilla-1"
      rglocation = "centralus"
    }
    "rg-east-us-mozilla-1" = {
      rgname     = "east-us-mozilla-1"
      rglocation = "eastus"
    }
    "rg-east-us-2-mozilla-1" = {
      rgname     = "east-us-2-mozilla-1"
      rglocation = "eastus2"
    }
    "rg-north-central-us-mozilla-1" = {
      rgname     = "north-central-us-mozilla-1"
      rglocation = "northcentralus"
    }
    "rg-south-central-us-mozilla-1" = {
      rgname     = "south-central-us-mozilla-1"
      rglocation = "southcentralus"
    }
    "rg-west-us-mozilla-1" = {
      rgname     = "west-us-mozilla-1"
      rglocation = "westus"
    }
    "rg-west-us-2-mozilla-1" = {
      rgname     = "west-us-2-mozilla-1"
      rglocation = "westus2"
    }
  }
}