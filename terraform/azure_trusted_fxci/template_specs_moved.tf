moved {
  from = azapi_resource.template_spec_taskcluster_arm_template
  to   = azapi_resource.template_spec["taskcluster-arm-template"]
}

moved {
  from = azapi_resource.template_spec_version_taskcluster_arm_template_1_0
  to   = azapi_resource.template_spec_version["taskcluster-arm-template-1.0"]
}

moved {
  from = azapi_resource.template_spec_version_taskcluster_arm_template_2_0
  to   = azapi_resource.template_spec_version["taskcluster-arm-template-2.0"]
}

moved {
  from = azapi_resource.template_spec_taskcluster_arm_template_relops
  to   = azapi_resource.template_spec["taskcluster-arm-template-relops"]
}

moved {
  from = azapi_resource.template_spec_version_taskcluster_arm_template_relops_1_0
  to   = azapi_resource.template_spec_version["taskcluster-arm-template-relops-1.0"]
}
