#!/bin/bash

packer build -force create-base.pkr.hcl;
packer build -force -var="vm_name=sonoma-base" disable-sip.pkr.hcl;
packer build -force -var="vm_name=sonoma-base" puppet-setup-phase1.pkr.hcl;
packer build -force -var="vm_name=sonoma-base" puppet-setup-phase2.pkr.hcl;
