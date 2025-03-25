# Tart CI Setup Script

🚀 This experimental bash script automates the setup of a Tart-based VM environment on macOS hosts for CI testing.

## Features

- ✅ Installs Google Cloud SDK (gcloud) if not already installed
- 🔐 Authenticates with Google Cloud using a service account key
- 🔑 Configures Docker authentication for Google Artifact Registry
- 📦 Installs [Tart](https://github.com/cirruslabs/tart) if not present
- ⬇️ Pulls the latest Tart image from GCP Artifact Registry
- 🧰 Installs [Cilicon](https://github.com/cirruslabs/cilicon) for managing Tart VMs
- 📝 Creates a preconfigured `cilicon.yml` config
- 🚀 Launches Cilicon

## Requirements

- macOS
- Internet access to download dependencies
- `GOOGLE_APPLICATION_CREDENTIALS` must be set in your environment

## Usage

1. Export your GCP credentials:
    ```bash
    export GOOGLE_APPLICATION_CREDENTIALS="/path/to/ci-tart-puller-key.json"
    ```

2. Run the script:
    ```bash
    ./setup_tart_ci.sh
    ```

## Notes

- This script should **not** be run as root.
- The Tart image and Cilicon config are hardcoded but can be modified in the script.
- The script creates and installs tools to the current user context and modifies shell profiles (`.bashrc` / `.zshrc`).

## License

MIT © Mozilla Platform Ops Team