# MaaS network ports
# https://maas.io/docs/security
variable "maas_ports" {
  description = "maas ports"
  type = map(object({
    begin = number
    end   = number
    proto = string
  }))
  default = {
    "regional_api" = {
      begin = 5240
      end   = 5240
      proto = "tcp"
    }
    "rackd_http" = {
      begin = 5248
      end   = 5248
      proto = "tcp"
    }
    "maas_internal" = {
      begin = 5241
      end   = 5247
      proto = "tcp"
    }
    "regional_rpc" = {
      begin = 5250
      end   = 5270
      proto = "tcp"
    }
  }
}

output "maas_ports" {
  value = var.maas_ports
}

variable "maas_mdc1_wintest_rackd_mac_address" {
  type = string
}

variable "maas_mdc1_test_rackd_mac_address" {
  type = string
}

