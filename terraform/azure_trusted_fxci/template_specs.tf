locals {
  template_spec_resource_group_id = "/subscriptions/a30e97ab-734a-4f3b-a0e4-c51c0bff0701/resourceGroups/template-spec"

  template_specs = {
    "taskcluster-arm-template"        = ["1.0", "2.0", "2.1"]
    "taskcluster-arm-template-relops" = ["1.0"]
  }

  template_spec_versions = merge([
    for name, versions in local.template_specs : {
      for version in versions : "${name}-${version}" => {
        name    = name
        version = version
      }
    }
  ]...)
}

resource "azapi_resource" "template_spec" {
  for_each = local.template_specs

  type      = "Microsoft.Resources/templateSpecs@2022-02-01"
  name      = each.key
  parent_id = local.template_spec_resource_group_id
  location  = "eastus"

  body = {
    properties = {}
  }
}

resource "azapi_resource" "template_spec_version" {
  for_each = local.template_spec_versions

  type      = "Microsoft.Resources/templateSpecs/versions@2022-02-01"
  name      = each.value.version
  parent_id = azapi_resource.template_spec[each.value.name].id
  location  = "eastus"

  body = {
    properties = {
      mainTemplate = jsondecode(file("${path.module}/template_specs/${each.key}.json"))
    }
  }
}
