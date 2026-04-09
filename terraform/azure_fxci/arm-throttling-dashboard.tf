locals {
  fxci_arm_throttling_dashboard_subscription_resource_id = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"

  fxci_arm_throttling_dashboard_overview_markdown = <<-MARKDOWN
  ## FXCI ARM Throttling
  This dashboard is the shared entry point for Azure Resource Manager subscription throttling in FXCI Azure DevTest Subscription.

  - Subscription resource: `${local.fxci_arm_throttling_dashboard_subscription_resource_id}`
  - Start with the `Traffic` metric and add `StatusCode = 429`.
  - High-signal filters for the current FXCI issue: `Namespace = MICROSOFT.RESOURCES`, `OperationType = write`.
  - Click a chart to open Metrics explorer and split or filter by `RequestRegion`, `Namespace`, or `OperationType`.
  MARKDOWN

  fxci_arm_throttling_dashboard_drilldown_markdown = <<-MARKDOWN
  ### How to confirm subscription bucket pressure
  1. Re-run a failing `az` command with `--debug`.
  2. Capture the `429` response and inspect `x-ms-ratelimit-remaining-subscription-reads` or `x-ms-ratelimit-remaining-subscription-writes`.
  3. If those headers are near `0`, the general ARM subscription bucket is being exhausted.

  Docs:
  - [Monitor Azure Resource Manager](https://learn.microsoft.com/azure/azure-resource-manager/management/monitor-resource-manager)
  - [Understand how Azure Resource Manager throttles requests](https://learn.microsoft.com/azure/azure-resource-manager/management/request-limits-and-throttling)
  MARKDOWN
}

resource "azapi_resource" "fxci_arm_throttling_dashboard" {
  type                      = "Microsoft.Portal/dashboards@2020-09-01-preview"
  name                      = "arm-throttle-fxci"
  parent_id                 = azurerm_resource_group.rg-central-us-runbooks.id
  location                  = azurerm_resource_group.rg-central-us-runbooks.location
  schema_validation_enabled = false

  tags = merge(
    local.common_tags,
    {
      Name           = "arm-throttle-fxci"
      "hidden-title" = "FXCI ARM Throttling"
    }
  )

  body = {
    properties = {
      lenses = [
        {
          order = 0
          parts = [
            {
              position = {
                x       = 0
                y       = 0
                rowSpan = 3
                colSpan = 11
              }
              metadata = {
                inputs = []
                type   = "Extension/HubsExtension/PartType/MarkdownPart"
                settings = {
                  content = {
                    settings = {
                      content  = local.fxci_arm_throttling_dashboard_overview_markdown
                      title    = "FXCI ARM Throttling"
                      subtitle = "Azure Resource Manager subscription throttling"
                    }
                  }
                }
              }
            },
            {
              position = {
                x       = 0
                y       = 3
                rowSpan = 4
                colSpan = 6
              }
              metadata = {
                inputs = [
                  {
                    name = "queryInputs"
                    value = {
                      timespan = {
                        duration = "P7D"
                      }
                      id        = local.fxci_arm_throttling_dashboard_subscription_resource_id
                      chartType = 0
                      metrics = [
                        {
                          name       = "Traffic"
                          resourceId = local.fxci_arm_throttling_dashboard_subscription_resource_id
                        }
                      ]
                    }
                  }
                ]
                type = "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart"
              }
            },
            {
              position = {
                x       = 6
                y       = 3
                rowSpan = 4
                colSpan = 5
              }
              metadata = {
                inputs = [
                  {
                    name = "queryInputs"
                    value = {
                      timespan = {
                        duration = "P7D"
                      }
                      id        = local.fxci_arm_throttling_dashboard_subscription_resource_id
                      chartType = 0
                      metrics = [
                        {
                          name       = "Latency"
                          resourceId = local.fxci_arm_throttling_dashboard_subscription_resource_id
                        }
                      ]
                    }
                  }
                ]
                type = "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart"
              }
            },
            {
              position = {
                x       = 0
                y       = 7
                rowSpan = 5
                colSpan = 11
              }
              metadata = {
                inputs = []
                type   = "Extension/HubsExtension/PartType/MarkdownPart"
                settings = {
                  content = {
                    settings = {
                      content = local.fxci_arm_throttling_dashboard_drilldown_markdown
                      title   = "Operational notes"
                    }
                  }
                }
              }
            }
          ]
        }
      ]
    }
  }
}
