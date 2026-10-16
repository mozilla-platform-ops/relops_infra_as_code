data "azurerm_firewall_policy" "run" {
  name                = "egress-fw-policy"
  resource_group_name = data.azurerm_resource_group.clauditor.name
}

# Add harness bootstrap/ARM access without taking ownership of the existing allowlist.
resource "azurerm_firewall_policy_rule_collection_group" "windows_isolation" {
  name               = "fuzzing-harness"
  firewall_policy_id = data.azurerm_firewall_policy.run.id
  priority           = 210

  application_rule_collection {
    name     = "harness-bootstrap"
    priority = 210
    action   = "Allow"

    rule {
      name             = "harness-https"
      source_addresses = [local.harness_subnet_prefix]
      destination_fqdns = [
        "management.azure.com",
        "ubuntu.com",
        "*.ubuntu.com",
        "docker.io",
        "*.docker.io",
        "production.cloudfront.docker.com",
        "r2.cloudflarestorage.com",
        "*.r2.cloudflarestorage.com",
      ]
      protocols {
        type = "Https"
        port = 443
      }
    }
    rule {
      name              = "ubuntu-packages"
      source_addresses  = [local.harness_subnet_prefix]
      destination_fqdns = ["ubuntu.com", "*.ubuntu.com"]
      protocols {
        type = "Http"
        port = 80
      }
    }
  }
}
