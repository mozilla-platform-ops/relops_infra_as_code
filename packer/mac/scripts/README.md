# 🛰️ Tart CI Toolkit

This directory contains tools for provisioning and managing Tart-based macOS CI environments.

## 📁 Scripts

### 1. `host_provisioner.sh`

🚀 This experimental bash script automates the setup of a Tart-based VM environment on macOS hosts for CI testing.

#### Features

- ✅ Installs Google Cloud SDK (gcloud) if not already installed
- 🔐 Authenticates with Google Cloud using a service account key
- 🔑 Configures Docker authentication for Google Artifact Registry
- 📦 Installs [Tart](https://github.com/cirruslabs/tart) if not present
- ⬇️ Pulls the latest Tart image from GCP Artifact Registry
- 🧰 Installs [Cilicon](https://github.com/cirruslabs/cilicon) for managing Tart VMs
- 🔁 Clones and randomizes VMs with unique MAC and serial numbers
- 📝 Creates a preconfigured `cilicon.yml` config
- 🚀 Launches Cilicon to run the VMs

#### Requirements

- macOS
- Internet access to download dependencies
- `GOOGLE_APPLICATION_CREDENTIALS` must be set in your environment

#### Usage

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/ci-tart-puller-key.json"
./host_provisioner.sh
```

---

### 2. `orbit.py`

🧠 A Python-based CLI tool for discovering and interacting with Tart-based VMs running on a host system.

#### Features

- 🔍 Discovers running Tart VMs via ARP table analysis
- 🖥️ Displays hostname, IP, and MAC for each VM
- 🔐 Supports SSH-based access (username/password or key)


#### Requirements

- Python 3.8+
- `rich`, `fabric`, `invoke` libraries

#### Usage

```bash
python orbit.py
```

Follow the prompts to discover, connect to, and manage your Tart VMs.

---

## License

MIT © Mozilla Platform Ops Team
