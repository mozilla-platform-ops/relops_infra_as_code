locals {
  fxci_template_spec_resource_group_id = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/resourceGroups/template-spec"

  fxci_template_spec_ids = {
    taskcluster_arm_template                = "${local.fxci_template_spec_resource_group_id}/providers/Microsoft.Resources/templateSpecs/taskcluster-arm-template"
    taskcluster_arm_template_dedicated_host = "${local.fxci_template_spec_resource_group_id}/providers/Microsoft.Resources/templateSpecs/taskcluster-arm-template-dedicated-host"
    taskcluster_arm_template_relops         = "${local.fxci_template_spec_resource_group_id}/providers/Microsoft.Resources/templateSpecs/taskcluster-arm-template-relops"
    taskcluster_arm_template_v6_nvme        = "${local.fxci_template_spec_resource_group_id}/providers/Microsoft.Resources/templateSpecs/taskcluster-arm-template-v6-nvme"
  }
}

resource "azapi_resource" "template_spec_taskcluster_arm_template" {
  type      = "Microsoft.Resources/templateSpecs@2022-02-01"
  name      = "taskcluster-arm-template"
  parent_id = local.fxci_template_spec_resource_group_id
  location  = "eastus"

  body = {
    properties = {}
  }
}

resource "azapi_resource" "template_spec_taskcluster_arm_template_dedicated_host" {
  type      = "Microsoft.Resources/templateSpecs@2022-02-01"
  name      = "taskcluster-arm-template-dedicated-host"
  parent_id = local.fxci_template_spec_resource_group_id
  location  = "eastus"

  body = {
    properties = {}
  }
}

resource "azapi_resource" "template_spec_taskcluster_arm_template_relops" {
  type      = "Microsoft.Resources/templateSpecs@2022-02-01"
  name      = "taskcluster-arm-template-relops"
  parent_id = local.fxci_template_spec_resource_group_id
  location  = "eastus"

  body = {
    properties = {}
  }
}

resource "azapi_resource" "template_spec_taskcluster_arm_template_v6_nvme" {
  type      = "Microsoft.Resources/templateSpecs@2022-02-01"
  name      = "taskcluster-arm-template-v6-nvme"
  parent_id = local.fxci_template_spec_resource_group_id
  location  = "eastus"

  body = {
    properties = {}
  }
}

resource "azapi_resource" "template_spec_version_taskcluster_arm_template_1_0" {
  type      = "Microsoft.Resources/templateSpecs/versions@2022-02-01"
  name      = "1.0"
  parent_id = local.fxci_template_spec_ids.taskcluster_arm_template
  location  = "eastus"

  body = {
    properties = {
      mainTemplate = jsondecode(file("${path.module}/template_specs/taskcluster-arm-template-1.0.json"))
    }
  }

  depends_on = [azapi_resource.template_spec_taskcluster_arm_template]
}

resource "azapi_resource" "template_spec_version_taskcluster_arm_template_dedicated_host_1_0" {
  type      = "Microsoft.Resources/templateSpecs/versions@2022-02-01"
  name      = "1.0"
  parent_id = local.fxci_template_spec_ids.taskcluster_arm_template_dedicated_host
  location  = "eastus"

  body = {
    properties = {
      mainTemplate = jsondecode(file("${path.module}/template_specs/taskcluster-arm-template-dedicated-host-1.0.json"))
    }
  }

  depends_on = [azapi_resource.template_spec_taskcluster_arm_template_dedicated_host]
}

resource "azapi_resource" "template_spec_version_taskcluster_arm_template_relops_1_0" {
  type      = "Microsoft.Resources/templateSpecs/versions@2022-02-01"
  name      = "1.0"
  parent_id = local.fxci_template_spec_ids.taskcluster_arm_template_relops
  location  = "eastus"

  body = {
    properties = {
      mainTemplate = jsondecode(file("${path.module}/template_specs/taskcluster-arm-template-relops-1.0.json"))
    }
  }

  depends_on = [azapi_resource.template_spec_taskcluster_arm_template_relops]
}

resource "azapi_resource" "template_spec_version_taskcluster_arm_template_relops_2_0" {
  type      = "Microsoft.Resources/templateSpecs/versions@2022-02-01"
  name      = "2.0"
  parent_id = local.fxci_template_spec_ids.taskcluster_arm_template_relops
  location  = "eastus"

  body = {
    properties = {
      mainTemplate = jsondecode(file("${path.module}/template_specs/taskcluster-arm-template-relops-2.0.json"))
    }
  }

  depends_on = [azapi_resource.template_spec_taskcluster_arm_template_relops]
}

resource "azapi_resource" "template_spec_version_taskcluster_arm_template_v6_nvme_1_0" {
  type      = "Microsoft.Resources/templateSpecs/versions@2022-02-01"
  name      = "1.0"
  parent_id = local.fxci_template_spec_ids.taskcluster_arm_template_v6_nvme
  location  = "eastus"

  body = {
    properties = {
      mainTemplate = jsondecode(file("${path.module}/template_specs/taskcluster-arm-template-v6-nvme-1.0.json"))
    }
  }

  depends_on = [azapi_resource.template_spec_taskcluster_arm_template_v6_nvme]
}
