locals {
  trusted_fxci_template_spec_resource_group_id = "/subscriptions/a30e97ab-734a-4f3b-a0e4-c51c0bff0701/resourceGroups/template-spec"

  trusted_fxci_template_spec_ids = {
    taskcluster_arm_template        = "${local.trusted_fxci_template_spec_resource_group_id}/providers/Microsoft.Resources/templateSpecs/taskcluster-arm-template"
    taskcluster_arm_template_relops = "${local.trusted_fxci_template_spec_resource_group_id}/providers/Microsoft.Resources/templateSpecs/taskcluster-arm-template-relops"
  }
}

resource "azapi_resource" "template_spec_taskcluster_arm_template" {
  type      = "Microsoft.Resources/templateSpecs@2022-02-01"
  name      = "taskcluster-arm-template"
  parent_id = local.trusted_fxci_template_spec_resource_group_id
  location  = "eastus"

  body = {
    properties = {}
  }
}

resource "azapi_resource" "template_spec_taskcluster_arm_template_relops" {
  type      = "Microsoft.Resources/templateSpecs@2022-02-01"
  name      = "taskcluster-arm-template-relops"
  parent_id = local.trusted_fxci_template_spec_resource_group_id
  location  = "eastus"

  body = {
    properties = {}
  }
}

resource "azapi_resource" "template_spec_version_taskcluster_arm_template_1_0" {
  type      = "Microsoft.Resources/templateSpecs/versions@2022-02-01"
  name      = "1.0"
  parent_id = local.trusted_fxci_template_spec_ids.taskcluster_arm_template
  location  = "eastus"

  body = {
    properties = {
      mainTemplate = jsondecode(file("${path.module}/template_specs/taskcluster-arm-template-1.0.json"))
    }
  }

  depends_on = [azapi_resource.template_spec_taskcluster_arm_template]
}

resource "azapi_resource" "template_spec_version_taskcluster_arm_template_relops_1_0" {
  type      = "Microsoft.Resources/templateSpecs/versions@2022-02-01"
  name      = "1.0"
  parent_id = local.trusted_fxci_template_spec_ids.taskcluster_arm_template_relops
  location  = "eastus"

  body = {
    properties = {
      mainTemplate = jsondecode(file("${path.module}/template_specs/taskcluster-arm-template-relops-1.0.json"))
    }
  }

  depends_on = [azapi_resource.template_spec_taskcluster_arm_template_relops]
}
