# macOS CI Automation - Packer + Tart

This project automates the provisioning of macOS virtual machines for CI using **Packer** and **Tart**. The process consists of **four phases**, ensuring a fully configured system with Puppet.

## 🚀 Overview of the Build Process

1. **Create Base Image** - Installs macOS from IPSW and configures the initial admin account.
2. **Disable SIP** - Boots into macOS recovery and disables System Integrity Protection (SIP).
3. **Puppet Setup Phase 1** - Runs Puppet with a subset of configurations (TCC/SafariDriver excluded).
4. **Puppet Setup Phase 2** - Re-runs Puppet after a reboot to apply TCC and SafariDriver settings.

## 🔧 Prerequisites

- Install **Packer**: https://developer.hashicorp.com/packer/downloads
- Install **Tart**: https://github.com/cirruslabs/tart
- Ensure you have **Packer plugins** installed:
  ```sh
  packer plugins install github.com/cirruslabs/tart
  ```
- **AWS S3 access** (for downloading Puppet and scripts).
- **Ensure the `vault.yaml` file** is available in `/Users/admin/Downloads/`.

## 🛠 Running the Full Build

To execute all steps automatically, **run the `builder.sh` script**:

```sh
cd tester/
chmod +x builder.sh
./builder.sh
```

This script will execute:
```sh
packer build -force create-base.pkr.hcl;
packer build -force -var="vm_name=sonoma-base" disable-sip.pkr.hcl;
packer build -force -var="vm_name=sonoma-base" puppet-setup-phase1.pkr.hcl;
packer build -force -var="vm_name=sonoma-base" puppet-setup-phase2.pkr.hcl;
```

## 📜 Phase Breakdown

### 1️⃣ Create Base Image
- Installs macOS from IPSW.
- Creates an admin user (`admin`).
- Enables SSH access.

### 2️⃣ Disable SIP
- Boots into **macOS Recovery Mode**.
- Disables **System Integrity Protection (SIP)**.
- Reboots back to macOS.

### 3️⃣ Puppet Setup Phase 1
- Installs necessary dependencies (Rosetta, Xcode CLT, Puppet).
- Clones **ronin_puppet** repo.
- **Runs Puppet with TCC and SafariDriver temporarily disabled**.
- **Reboots after the first run**.

### 4️⃣ Puppet Setup Phase 2
- **Restores TCC & SafariDriver modules**.
- Runs Puppet **again** to apply full configurations.
- Ensures a **clean exit**.

## 🔥 Key Workarounds & Fixes

### 🛑 Fixing TCC Permissions & SafariDriver
- These modules **must be disabled** on the first Puppet run.
- They are **re-enabled after reboot** in Phase 2.

### 🔄 Ensuring Clean Reboots
- The **first Puppet run fails** (expected) due to missing users (`cltbld`).
- **We catch the failure and trigger a reboot**.
- The **second run finalizes** all remaining configs.

## ❌ Troubleshooting

### 1️⃣ Stuck on Accessibility or Welcome Screens
- Ensure `Disable Setup Assistant` step is applied in Puppet.

### 2️⃣ Puppet Not Applying Correctly?
```sh
sudo /opt/puppetlabs/bin/puppet agent --test --debug
```

### 3️⃣ Verifying SIP Status
```sh
csrutil status
```

## 🎉 Next Steps
- Validate builds in the CI pipeline.
- Expand support for **multiple macOS versions**.
- Automate VM name assignment dynamically.
