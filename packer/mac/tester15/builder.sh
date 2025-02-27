#!/bin/bash

# Define default values (modify as needed)
DEFAULT_VM_NAME="sequoia-base"

# Allow user to override via environment variables
VM_NAME="${VM_NAME:-$DEFAULT_VM_NAME}"

# Prompt user for vault file path
if [[ -z "$VAULT_FILE" ]]; then
    read -p "🔑 Enter the path to the Vault file: " VAULT_FILE
fi

# Ensure vault file exists
if [[ ! -f "$VAULT_FILE" ]]; then
    echo "❌ Vault file not found at '$VAULT_FILE'"
    echo "Please specify the correct path and try again."
    exit 1
fi

# Confirm settings before running
echo "⚡ Starting macOS CI Image Build..."
echo "  - VM Name: $VM_NAME"
echo "  - Vault File: $VAULT_FILE"
echo ""

# Run the packer builds
packer build -force create-base.pkr.hcl;
packer build -force -var="vm_name=$VM_NAME" disable-sip.pkr.hcl;
packer build -force -var="vm_name=$VM_NAME" -var="vault_file=$VAULT_FILE" puppet-setup-phase1.pkr.hcl;
packer build -force -var="vm_name=$VM_NAME" puppet-setup-phase2.pkr.hcl;

echo "✅ Build process completed successfully!"