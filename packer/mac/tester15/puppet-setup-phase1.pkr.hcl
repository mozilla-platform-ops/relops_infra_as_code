packer {
  required_plugins {
    tart = {
      version = ">= 1.12.0"
      source  = "github.com/cirruslabs/tart"
    }
  }
}

# Define a variable for VM name (allows dynamic selection)
variable "vm_name" {
  type    = string
  default = "sequoia-base"
}

source "tart-cli" "puppet-setup-phase1" {
  vm_name   = "${var.vm_name}"  # Use dynamic variable
  cpu_count = 4
  memory_gb = 8
  disk_size_gb = 100
  ssh_password = "admin"
  ssh_username = "admin"
  ssh_timeout  = "120s"
}

build {
  name    = "puppet-setup-phase1"
  sources = ["source.tart-cli.puppet-setup-phase1"]

  provisioner "file" {
    source      = "/Users/admin/Downloads/vault.yaml"
    destination = "/tmp/vault.yaml"
  }

  provisioner "shell" {
    inline = [

      "echo 'Ensuring system paths exist...'",
      "echo admin | sudo -S mkdir -p /usr/local/bin/",
      "echo admin | sudo -S chmod 755 /usr/local/bin/",
      "echo admin | sudo -S mkdir -p /Library/Frameworks/Python.framework/Versions/3.11/bin/",
      "echo admin | sudo -S ln -sf /usr/bin/pip3 /Library/Frameworks/Python.framework/Versions/3.11/bin/pip3",

      "echo 'Ensuring Rosetta 2 is installed...'",
      "if /usr/bin/pgrep oahd >/dev/null 2>&1; then",
      "  echo 'Rosetta 2 is already installed'",
      "else",
      "  echo 'Installing Rosetta 2...'",
      "  echo admin | sudo -S softwareupdate --install-rosetta --agree-to-license",
      "fi",

      # Ensure vault.yaml is where bootstrap_mojave.sh expects it
      "echo admin | sudo -S mkdir -p /var/root/",
      "echo admin | sudo -S cp /tmp/vault.yaml /var/root/vault.yaml",

      "echo 'Enabling passwordless sudo for admin...'",
      "echo admin | sudo -S sh -c 'mkdir -p /etc/sudoers.d/ && echo \"admin ALL=(ALL) NOPASSWD: ALL\" | tee /etc/sudoers.d/admin-nopasswd'",

      "echo 'Installing Command Line Tools...'",
      "touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress",
      "softwareupdate --list | sed -n 's/.*Label: \\(Command Line Tools for Xcode-.*\\)/\\1/p' | xargs -I {} softwareupdate --install '{}'",
      "rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress",

      # Ensure Puppet is installed before running (download from S3)
      "if ! command -v /opt/puppetlabs/bin/puppet &> /dev/null; then",
      "  echo 'Downloading Puppet from S3...'",
      "  curl -o /tmp/puppet-agent-7.28.0-1-installer.pkg https://ronin-puppet-package-repo.s3.us-west-2.amazonaws.com/macos/public/common/puppet-agent-7.28.0-1-installer.pkg",
      "  echo 'Installing Puppet...'",
      "  echo admin | sudo -S installer -pkg /tmp/puppet-agent-7.28.0-1-installer.pkg -target /",
      "fi",

      # Ensure Puppet is in the PATH
      "export PATH=$PATH:/opt/puppetlabs/bin",

      # Ensure the Puppet repo is cloned from the correct branch
      "if [ ! -d /Users/admin/Desktop/puppet/ronin_puppet ]; then",
      "  echo 'Cloning ronin_puppet repository...'",
      "  git clone --branch master https://github.com/mozilla-platform-ops/ronin_puppet.git /Users/admin/Desktop/puppet/ronin_puppet",
      "fi",

      "echo 'Modifying hiera.yaml to include local vault path...'",
      "sudo tee /Users/admin/Desktop/puppet/ronin_puppet/hiera.yaml > /dev/null << 'EOF'",
      "---",
      "version: 5",
      "defaults:",
      "  data_hash: yaml_data",
      "  datadir: data",
      "",
      "hierarchy:",
      "  - name: \"local\"",
      "    path: \"/var/root/vault.yaml\"",
      "",
      "  - name: \"Per-role data\"",
      "    path: \"roles/%%{facts.puppet_role}.yaml\"",
      "",
      "  - name: \"Per-role Windows\"",
      "    path: \"roles/%%{facts.custom_win_role}.yaml\"",
      "",
      "  - name: \"Per-OS defaults\"",
      "    path: \"os/%%{facts.os.family}.yaml\"",
      "",
      "  - name: \"Secrets generated from Vault\"",
      "    path: \"secrets/vault.yaml\"",
      "",
      "  - name: \"Common data to all\"",
      "    path: \"common.yaml\"",
      "EOF",

      # Ensure /etc/facter/facts.d exists
      "echo admin | sudo -S mkdir -p /etc/facter/facts.d/",

      # Set Puppet role and ensure it's readable
      "echo 'puppet_role=gecko_t_osx_1500_m_vms' | sudo tee /etc/facter/facts.d/puppet_role.txt > /dev/null",
      "sudo chmod 644 /etc/facter/facts.d/puppet_role.txt",

      # Ensure /etc/puppet_role exists and matches Facter
      "echo 'gecko_t_osx_1500_m_vms' | sudo tee /etc/puppet_role > /dev/null",
      "sudo chmod 644 /etc/puppet_role",

      # Remove Facter cache to force reload
      "echo admin | sudo -S rm -rf /opt/puppetlabs/facter/cache/",

      # Verify fact is correctly set
      "echo 'Verifying puppet_role fact...'",
      "sudo /opt/puppetlabs/bin/facter puppet_role",

      # Verify /etc/puppet_role exists before continuing
      "if [ ! -f /etc/puppet_role ]; then",
      "  echo 'ERROR: /etc/puppet_role was not created. Exiting...'",
      "  exit 1",
      "fi",

      # Small delay to ensure Facter fully loads the new fact
      "sleep 3",

      # Download bootstrap script
      "echo 'Downloading bootstrap_mojave_tester.sh...'",
      "curl -o /tmp/bootstrap_mojave_tester.sh https://ronin-puppet-package-repo.s3.us-west-2.amazonaws.com/macos/public/common/bootstrap_mojave_tester.sh",
      "chmod +x /tmp/bootstrap_mojave_tester.sh",

      "echo 'Temporarily commenting out macos_tcc_perms, safaridriver, and macos_directory_cleaner in role manifest...'",
      "sudo sed -i '.bak' '/macos_tcc_perms/s/^/#/' /Users/admin/Desktop/puppet/ronin_puppet/modules/roles_profiles/manifests/roles/gecko_t_osx_1500_m_vms.pp",
      "sudo sed -i '.bak' '/safaridriver/s/^/#/' /Users/admin/Desktop/puppet/ronin_puppet/modules/roles_profiles/manifests/roles/gecko_t_osx_1500_m_vms.pp",
      "sudo sed -i '.bak' '/macos_directory_cleaner/s/^/#/' /Users/admin/Desktop/puppet/ronin_puppet/modules/roles_profiles/manifests/roles/gecko_t_osx_1500_m_vms.pp",
      "sudo sed -i '.bak' '/pipconf/s/^/#/' /Users/admin/Desktop/puppet/ronin_puppet/modules/roles_profiles/manifests/roles/gecko_t_osx_1500_m_vms.pp",

     "echo 'Running bootstrap_mojave_tester.sh (first attempt)...'",
      "if ! (echo admin | sudo -S /tmp/bootstrap_mojave_tester.sh); then",
      "  echo 'First Puppet run failed. Rebooting...'",
      "  sleep 10",  # Prevent Packer from failing before reboot
      "  sudo shutdown -r now",
      "  exit 0",
      "fi"
    ]
  }
}