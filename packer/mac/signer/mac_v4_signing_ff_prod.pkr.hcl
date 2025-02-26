packer {
  required_plugins {
    tart = {
      version = ">= 1.12.0"
      source  = "github.com/cirruslabs/tart"
    }
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "tart-cli" "tart" {
  # This can change to a local directory for testing  
  from_ipsw    = "https://updates.cdn-apple.com/2024SummerFCS/fullrestores/052-69922/F5DA2B64-25EB-4370-9E89-FA5689859796/UniversalMac_14.6_23G80_Restore.ipsw"
  vm_name      = "sonoma-signer"
  cpu_count    = 4
  memory_gb    = 8
  disk_size_gb = 50
  ssh_password = "admin"
  ssh_username = "admin"
  ssh_timeout  = "120s"
  boot_command = [
    # hello, hola, bonjour, etc.
    "<wait60s><spacebar>",
    # Language: most of the times we have a list of "English"[1], "English (UK)", etc. with
    # "English" language already selected. If we type "english", it'll cause us to switch
    # to the "English (UK)", which is not what we want. To solve this, we switch to some other
    # language first, e.g. "Italiano" and then switch back to "English". We'll then jump to the
    # first entry in a list of "english"-prefixed items, which will be "English".
    #
    # [1]: should be named "English (US)", but oh well 🤷
    "<wait30s>italiano<esc>english<enter>",
    # Select Your Country and Region
    "<wait30s>united states<leftShiftOn><tab><leftShiftOff><spacebar>",
    # Written and Spoken Languages
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Accessibility
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Data & Privacy
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Migration Assistant
    "<wait10s><tab><tab><tab><spacebar>",
    # Sign In with Your Apple ID
    "<wait10s><leftShiftOn><tab><leftShiftOff><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Are you sure you want to skip signing in with an Apple ID?
    "<wait10s><tab><spacebar>",
    # Terms and Conditions
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # I have read and agree to the macOS Software License Agreement
    "<wait10s><tab><spacebar>",
    # Create a Computer Account
    "<wait10s>admin<tab><tab>admin<tab>admin<tab><tab><tab><spacebar>",
    # Enable Location Services
    "<wait30s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Are you sure you don't want to use Location Services?
    "<wait10s><tab><spacebar>",
    # Select Your Time Zone
    "<wait10s><tab>UTC<enter><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Analytics
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Screen Time
    "<wait10s><tab><spacebar>",
    # Siri
    "<wait10s><tab><spacebar><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Choose Your Look
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    # Enable Voice Over
    "<wait10s><leftAltOn><f5><leftAltOff><wait5s>v",
    # Now that the installation is done, open "System Settings"
    "<wait10s><leftAltOn><spacebar><leftAltOff>System Settings<enter>",
    # Navigate to "Sharing"
    "<wait10s><leftAltOn>f<leftAltOff>sharing<enter>",
    # Navigate to "Screen Sharing" and enable it
    "<wait10s><tab><tab><tab><tab><tab><spacebar>",
    # Navigate to "Remote Login" and enable it
    "<wait10s><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><spacebar>",
    # Disable Voice Over
    "<leftAltOn><f5><leftAltOff>",
  ]

  // A (hopefully) temporary workaround for Virtualization.Framework's
  // installation process not fully finishing in a timely manner
  create_grace_time = "30s"

  // Keep the recovery partition, otherwise it's not possible to "softwareupdate"
  recovery_partition = "keep"
}

build {
  sources = ["source.tart-cli.tart"]

  # File provisioners to transfer necessary files

  # For security reasons this will probably remain manual
  provisioner "file" {
    source      = "/Users/admin/Downloads/vault.yaml"
    destination = "/tmp/vault.yaml"
  }

  # Shell provisioner to configure the system
  provisioner "shell" {
    inline = [

      # Ensure Rosetta 2 is installed
      "if /usr/bin/pgrep oahd >/dev/null 2>&1; then echo 'Rosetta 2 is already installed'; else echo 'Installing Rosetta 2...'; echo admin | sudo -S softwareupdate --install-rosetta --agree-to-license; fi",

      # Enable passwordless sudo for admin
      "echo admin | sudo -S sh -c 'mkdir -p /etc/sudoers.d/ && echo \"admin ALL=(ALL) NOPASSWD: ALL\" | tee /etc/sudoers.d/admin-nopasswd'",

      # Ensure vault.yaml is where bootstrap_mojave.sh expects it
      "echo admin | sudo -S mkdir -p /var/root/",
      "echo admin | sudo -S cp /tmp/vault.yaml /var/root/vault.yaml",

      # Download and install Xcode from S3
      # ETA 2m45s
      "echo 'Downloading Xcode 16.2 from S3...'",
      "curl -o /tmp/Xcode_16.2.xip https://ronin-puppet-package-repo.s3.us-west-2.amazonaws.com/macos/public/common/Xcode_16.2.xip",

      # Extract and install Xcode
      "echo 'Extracting Xcode, this may take a while...'",
      "xip --expand /tmp/Xcode_16.2.xip",
      "echo admin | sudo -S mv Xcode.app /Applications/Xcode.app",
      "echo admin | sudo -S xcode-select --switch /Applications/Xcode.app/Contents/Developer",
      "echo admin | sudo -S xcodebuild -license accept",

      # Ensure Puppet is installed before running (download from S3)
      "if ! command -v /opt/puppetlabs/bin/puppet &> /dev/null; then echo 'Downloading Puppet from S3...'; curl -o /tmp/puppet-agent-7.28.0-1-installer.pkg https://ronin-puppet-package-repo.s3.us-west-2.amazonaws.com/macos/public/common/puppet-agent-7.28.0-1-installer.pkg && echo 'Installing Puppet...'; echo admin | sudo -S installer -pkg /tmp/puppet-agent-7.28.0-1-installer.pkg -target /; fi",

      # Ensure Puppet is in the PATH
      "export PATH=$PATH:/opt/puppetlabs/bin",

      # Ensure the Puppet repo is cloned from the correct branch
      "if [ ! -d /Users/admin/puppet/ronin_puppet ]; then echo 'Cloning ronin_puppet repository...'; git clone --branch macos-signer-latest https://github.com/mozilla-platform-ops/ronin_puppet.git /Users/admin/puppet/ronin_puppet; fi",

      # Install SignerBootstrap package from S3
      "echo 'Downloading SignerBootstrap.pkg from S3...'",
      "curl -o /tmp/SignerBootstrap.pkg https://ronin-puppet-package-repo.s3.us-west-2.amazonaws.com/macos/public/common/SignerBootstrap.pkg",
      "echo admin | sudo -S installer -pkg /tmp/SignerBootstrap.pkg -target /",
      "rm /tmp/SignerBootstrap.pkg",

      # Download bootstrap_mojave.sh from S3
      "echo 'Downloading bootstrap_mojave.sh from S3...'",
      "curl -o /tmp/bootstrap_mojave.sh https://ronin-puppet-package-repo.s3.us-west-2.amazonaws.com/macos/public/common/bootstrap_mojave.sh",

      # Ensure the script is executable
      "chmod +x /tmp/bootstrap_mojave.sh",

      # Run the bootstrap script as the last step
      # At present this fails the first run but the retry
      # timeout is 60 seconds. It will succeed the second run
      "echo 'Running bootstrap_mojave.sh...'",
      "echo admin | sudo -S /tmp/bootstrap_mojave.sh"
    ]
  }
}
