packer {
  required_plugins {
    tart = {
      version = ">= 1.12.0"
      source  = "github.com/cirruslabs/tart"
    }
  }
}

variable "vm_name" {
  type    = string
  default = "seqoia-tester"
}

source "tart-cli" "puppet-setup-phase2" {
  vm_name      = "${var.vm_name}"
  cpu_count    = 4
  memory_gb    = 8
  disk_size_gb = 100
  ssh_password = "admin"
  ssh_username = "admin"
  ssh_timeout  = "120s"
}

build {
  name    = "puppet-setup-phase2"
  sources = ["source.tart-cli.puppet-setup-phase2"]

  provisioner "file" {
  source      = "set_hostname.sh"
  destination = "/tmp/set_hostname.sh"
}

  provisioner "file" {
    source      = "com.mozilla.sethostname.plist"
    destination = "/tmp/com.mozilla.sethostname.plist"
  }

  provisioner "shell" {
    inline = [

      // Disable screensaver at login screen
      "sudo defaults write /Library/Preferences/com.apple.screensaver loginWindowIdleTime 0",
      // Disable screensaver for admin user
      "defaults -currentHost write com.apple.screensaver idleTime 0",
      // Prevent the VM from sleeping
      "sudo systemsetup -setsleep Off 2>/dev/null",

      "echo 'Setting up hostname auto-config at startup...'",

      # Move the script and set permissions
      "echo admin | sudo -S mv /tmp/set_hostname.sh /usr/local/bin/set_hostname.sh",
      "echo admin | sudo -S chmod +x /usr/local/bin/set_hostname.sh",

      # Move the launch daemon file and set permissions
      "echo admin | sudo -S mv /tmp/com.mozilla.sethostname.plist /Library/LaunchDaemons/com.mozilla.sethostname.plist",
      "echo admin | sudo -S chmod 644 /Library/LaunchDaemons/com.mozilla.sethostname.plist",
      "echo admin | sudo -S chown root:wheel /Library/LaunchDaemons/com.mozilla.sethostname.plist",

      # Load the daemon so it runs on startup
      "echo admin | sudo -S launchctl load /Library/LaunchDaemons/com.mozilla.sethostname.plist",

      "echo 'Hostname configuration is now active.'",

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

      "echo 'Restoring macos_tcc_perms, safaridriver, pipconf and macos_directory_cleaner in role manifest...'",
      "sudo sed -i '.bak' '/#.*macos_tcc_perms/s/^#//' /Users/admin/Desktop/puppet/ronin_puppet/modules/roles_profiles/manifests/roles/gecko_t_osx_1500_m_vms.pp",
      "sudo sed -i '.bak' '/#.*safaridriver/s/^#//' /Users/admin/Desktop/puppet/ronin_puppet/modules/roles_profiles/manifests/roles/gecko_t_osx_1500_m_vms.pp",
      "sudo sed -i '.bak' '/#.*macos_directory_cleaner/s/^#//' /Users/admin/Desktop/puppet/ronin_puppet/modules/roles_profiles/manifests/roles/gecko_t_osx_1500_m_vms.pp",
      "sudo sed -i '.bak' '/#.*pipconf/s/^#//' /Users/admin/Desktop/puppet/ronin_puppet/modules/roles_profiles/manifests/roles/gecko_t_osx_1500_m_vms.pp",

      "echo 'Re-running bootstrap_mojave_tester.sh (second attempt after reboot)...'",
      "echo admin | sudo -S /tmp/bootstrap_mojave_tester.sh || echo 'Puppet run completed with errors, but continuing...'",

      "sudo rm /var/root/vault.yaml",

      "sudo mkdir /var/tmp/semaphore",
      "sudo touch /var/tmp/semaphore/run-buildbot",

      "echo 'Finalizing setup. Ensuring clean exit...'",
      "exit 0"
    ]
  }
}