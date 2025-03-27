#!/bin/bash

# Experimental script to automate VM roll out on macOS hosts

# Requires ci-tart-puller-key.json GCP key to be set in the environment
# Requires Tart to be installed on the host, but it will be downloaded if missing.

set -e  # Exit on error
set -o pipefail  # Fail if any command in a pipeline fails

echo "🚀 Starting Tart CI Setup..."

# 🔹 1. Ensure GOOGLE_APPLICATION_CREDENTIALS is set
if [[ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]]; then
    echo "❌ ERROR: GOOGLE_APPLICATION_CREDENTIALS is not set!"
    echo "➡️  Set it using: export GOOGLE_APPLICATION_CREDENTIALS='/path/to/ci-tart-puller-key.json'"
    exit 1
fi

# 🔹 2. Install Google Cloud SDK (gcloud) if missing
if ! command -v gcloud &> /dev/null; then
    echo "🚀 Installing Google Cloud SDK (gcloud) non-interactively..."

    export CLOUD_SDK_DIR="$HOME/google-cloud-sdk"

    GCS_VERSION=$(curl -s https://dl.google.com/dl/cloudsdk/channels/rapid/components-2.json | awk -F'"version": "' '{print $2}' | awk -F'"' '{print $1}' | tr -d '[:space:]')
    GCS_ARCHIVE="google-cloud-sdk-$GCS_VERSION-darwin-arm.tar.gz"
    GCS_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/$GCS_ARCHIVE"

    echo "Downloading Google Cloud SDK: $GCS_URL"
    curl -sSL "$GCS_URL" -o gcloud-sdk.tar.gz

    mkdir -p "$CLOUD_SDK_DIR"
    tar -xzf gcloud-sdk.tar.gz -C "$CLOUD_SDK_DIR" --strip-components=1
    rm gcloud-sdk.tar.gz

    "$CLOUD_SDK_DIR"/install.sh --quiet
    export PATH=$CLOUD_SDK_DIR/bin:$PATH
    echo "export PATH=$CLOUD_SDK_DIR/bin:\$PATH" >> ~/.bashrc
    echo "export PATH=$CLOUD_SDK_DIR/bin:\$PATH" >> ~/.zshrc

    echo "✅ gcloud installation complete!"
else
    echo "✅ gcloud is already installed."
fi

# 🔹 3. Authenticate with GCP using the service account
echo "🔐 Authenticating with Google Cloud..."
gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"

# 🔹 4. Ensure authentication works
echo "✅ Checking active authentication..."
gcloud auth list

# 🔹 5. Configure Artifact Registry authentication
echo "🔑 Configuring authentication for Artifact Registry..."
gcloud auth configure-docker us-west1-docker.pkg.dev --quiet

# 🔹 6. Install Tart if missing
TART_BIN="/Applications/tart.app/Contents/MacOS/tart"

if ! command -v "$TART_BIN" &> /dev/null; then
    echo "📦 Tart not found, downloading..."
    curl -LO https://github.com/cirruslabs/tart/releases/latest/download/tart.tar.gz
    tar -xzvf tart.tar.gz

    if [ -d "/Applications/tart.app" ]; then
        echo "⚠️  /Applications/tart.app already exists. Skipping move."
    else
        mv tart.app /Applications/
    fi

    rm -rf tart.tar.gz tart.app
    echo "✅ Tart installed successfully!"
else
    echo "✅ Tart is already installed."
fi

# 🔹 7. Pull the latest Tart image from GCP
TART_IMAGE="us-west1-docker.pkg.dev/taskcluster-imaging/mac-images/sequoia-tester:latest"
LOCAL_NAME="sequoia-tester"

echo "⬇️  Checking if Tart image already exists locally..."
if "$TART_BIN" list | grep -q "$LOCAL_NAME"; then
    echo "✅ Tart image '$LOCAL_NAME' already exists. Skipping pull."
else
    echo "📦 Pulling Tart image from GCP: $TART_IMAGE"
    "$TART_BIN" pull "$TART_IMAGE"
    echo "✅ Tart image successfully pulled."
fi

# 🔹 8. Verify Tart image is available
echo "📂 Listing available Tart images..."
"$TART_BIN" list

# 🔹 9. Clone each vm with a unqiue name
echo "🚀 Cloning VMs..."
for i in 1 2; do
  VM_NAME="sequoia-tester-$i"
  if "$TART_BIN" list | grep -q "$VM_NAME"; then
    echo "⚠️  $VM_NAME already exists. Skipping clone."
  else
    "$TART_BIN" clone "$TART_IMAGE" "$VM_NAME"
    "$TART_BIN" set --random-serial "$VM_NAME"
    "$TART_BIN" set --random-mac "$VM_NAME"
  fi
done

echo "🚀 Installing Cilicon..."

# 🔹 10. Download Cilicon-3.zip from S3
CILICON_URL="https://ronin-puppet-package-repo.s3.us-west-2.amazonaws.com/macos/public/common/Cilicon-3.zip"
CILICON_ZIP="/tmp/Cilicon-3.zip"

echo "📥 Downloading Cilicon from $CILICON_URL..."
curl -sSL "$CILICON_URL" -o "$CILICON_ZIP"

# 🔹 11. Extract Cilicon into /Applications, force overwrite if exists
echo "📂 Extracting Cilicon to /Applications..."
unzip -o -q "$CILICON_ZIP" -d /Applications
rm "$CILICON_ZIP"

echo "✅ Cilicon installed successfully!"

# 🔹 12. Determine non-root user
if [[ $EUID -eq 0 ]]; then
    echo "❌ ERROR: Running as root. Cannot determine user home directory!"
    exit 1
fi

USER_HOME="$HOME"
CILICON_CONFIG="$USER_HOME/cilicon.yml"

# 🔹 13. Backup existing Cilicon config if it exists
if [[ -f "$CILICON_CONFIG" ]]; then
  mv "$CILICON_CONFIG" "$CILICON_CONFIG.bak.$(date +%s)"
  echo "🗂️  Backed up existing Cilicon config to $CILICON_CONFIG.bak"
fi

# 🔹 14. Create Cilicon config file
echo "📝 Creating Cilicon config at $CILICON_CONFIG..."
cat <<EOF > "$CILICON_CONFIG"
machines:
  - id: sequoia-tester-1
    source: "$USER_HOME/.tart/vms/sequoia-tester-1"
    provisioner:
      type: script
      config:
        run: |
          echo "Waiting for cltbld to trigger a reboot..."
          while true; do
            if who | grep -q cltbld; then
              echo "cltbld is logged in, waiting for reboot..."
              sleep 10
            else
              echo "cltbld is not logged in, keeping VM alive..."
              sleep 30
            fi
          done
    hardware:
      ramGigabytes: 8
      cpuCores: 4

  - id: sequoia-tester-2
    source: "$USER_HOME/.tart/vms/sequoia-tester-2"
    provisioner:
      type: script
      config:
        run: |
          echo "Waiting for cltbld to trigger a reboot..."
          while true; do
            if who | grep -q cltbld; then
              echo "cltbld is logged in, waiting for reboot..."
              sleep 10
            else
              echo "cltbld is not logged in, keeping VM alive..."
              sleep 30
            fi
          done
    hardware:
      ramGigabytes: 8
      cpuCores: 4
EOF

echo "✅ Cilicon configuration written to $CILICON_CONFIG"

# 🔹 15. Launch Cilicon
echo "🚀 Launching Cilicon..."
if ! pgrep -f "Cilicon.app" > /dev/null; then
  open -a /Applications/Cilicon.app
  echo "🚀 Cilicon launched!"
else
  echo "✅ Cilicon already running."
fi

echo "🎉 Setup complete! Cilicon is running!"