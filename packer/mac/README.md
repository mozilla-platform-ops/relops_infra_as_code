# macOS CI Automation - Packer + Tart + Ansible

This project automates the provisioning of macOS virtual machines for CI using **Packer**, **Tart**, and **Ansible**.
The process consists of **four phases**, ensuring a fully configured system with Puppet.

---

## 🚀 Overview of the Build Process

1. **Create Base Image** - Installs macOS from IPSW and configures the initial admin account.
2. **Disable SIP** - Boots into macOS recovery and disables System Integrity Protection (SIP).
3. **Puppet Setup Phase 1** - Runs Puppet with a subset of configurations (TCC/SafariDriver excluded).
4. **Puppet Setup Phase 2** - Re-runs Puppet after a reboot to apply TCC and SafariDriver settings.

---

## 🔧 Prerequisites

1. **Install Packer**: [Download Packer](https://developer.hashicorp.com/packer/downloads)
2. **Install Tart**: [Download Tart](https://github.com/cirruslabs/tart)
3. **Install Packer Plugins** (Tart & Ansible):
   ```sh
   packer plugins install github.com/cirruslabs/tart
   packer plugins install github.com/hashicorp/ansible
   ```
4. **Install Ansible** (Required for system updates):
   ```sh
   brew install ansible
   ```
5. **Ensure AWS S3 access** (for downloading Puppet and scripts).
6. **Use the provided `fake-vault.yaml` file** for testing.

---

## 🛠 Running the Full Build

To execute all steps automatically, **run the `builder.sh` script**:

```sh
cd tester15/
chmod +x builder.sh
./builder.sh
```

This script will execute:
```sh
packer build -force create-base.pkr.hcl;
packer build -force -var="vm_name=sequoia-base" disable-sip.pkr.hcl;
packer build -force -var="vm_name=sequoia-base" puppet-setup-phase1.pkr.hcl;
packer build -force -var="vm_name=sequoia-base" puppet-setup-phase2.pkr.hcl;
```

---

## 📜 Using the Fake Vault File

A **fake `fake-vault.yaml` file** is already included in the same directory as `builder.sh`.
To use it, simply **run the build script as usual**:

```sh
./builder.sh
```

If needed, you can explicitly set the vault file path before running the script:

```sh
export VAULT_FILE="$(pwd)/vault.yaml"
./builder.sh
```

This ensures the build process completes **successfully** without requiring real secrets.

---

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

---

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

---

## 🎉 Next Steps
- Validate builds in the CI pipeline.
