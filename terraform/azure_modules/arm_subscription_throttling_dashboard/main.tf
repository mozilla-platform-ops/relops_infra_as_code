terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
    }
  }
}

locals {
  subscription_resource_id = "/subscriptions/${var.subscription_id}"

  overview_markdown = <<-MARKDOWN
  ## ${var.dashboard_display_name}
  This dashboard is the shared entry point for Azure Resource Manager subscription throttling in ${var.subscription_display_name}.

  - Subscription resource: `${local.subscription_resource_id}`
  - Start with the `Traffic` metric and add `StatusCode = 429`.
  - High-signal filters for the current FXCI issue: `Namespace = MICROSOFT.RESOURCES`, `OperationType = write`.
  - Click a chart to open Metrics explorer and split or filter by `RequestRegion`, `Namespace`, or `OperationType`.
  MARKDOWN

  drilldown_markdown = <<-MARKDOWN
  ### How to confirm subscription bucket pressure
  1. Re-run a failing `az` command with `--debug`.
  2. Capture the `429` response and inspect `x-ms-ratelimit-remaining-subscription-reads` or `x-ms-ratelimit-remaining-subscription-writes`.
  3. If those headers are near `0`, the general ARM subscription bucket is being exhausted.

  Docs:
  - [Monitor Azure Resource Manager](https://learn.microsoft.com/azure/azure-resource-manager/management/monitor-resource-manager)
  - [Understand how Azure Resource Manager throttles requests](https://learn.microsoft.com/azure/azure-resource-manager/management/request-limits-and-throttling)
  MARKDOWN
}

resource "azapi_resource" "this" {
  type                      = "Microsoft.Portal/dashboards@2020-09-01-preview"
  name                      = var.dashboard_name
  parent_id                 = var.resource_group_id
  location                  = var.location
  schema_validation_enabled = false

  tags = merge(
    var.tags,
    {
      Name           = var.dashboard_name
      "hidden-title" = var.dashboard_display_name
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
                      content  = local.overview_markdown
                      title    = var.dashboard_display_name
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
                        duration = var.metric_timespan
                      }
                      id        = local.subscription_resource_id
                      chartType = 0
                      metrics = [
                        {
                          name       = "Traffic"
                          resourceId = local.subscription_resource_id
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
                        duration = var.metric_timespan
                      }
                      id        = local.subscription_resource_id
                      chartType = 0
                      metrics = [
                        {
                          name       = "Latency"
                          resourceId = local.subscription_resource_id
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
                      content = local.drilldown_markdown
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
