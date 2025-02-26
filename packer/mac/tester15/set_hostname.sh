#!/bin/bash
# This script sets the hostname based on the Mac's serial number

SERIAL_NUMBER=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $NF}')
HOSTNAME="mac-${SERIAL_NUMBER}"

echo "Setting system hostname to $HOSTNAME"

# Apply hostname settings
scutil --set ComputerName "$HOSTNAME"
scutil --set LocalHostName "$HOSTNAME"
scutil --set HostName "$HOSTNAME"

# Confirm the change
echo "New Hostname: $(scutil --get HostName)"

# Update /opt/worker/worker-runner-config.yaml
CONFIG_FILE="/opt/worker/worker-runner-config.yaml"

if [ -f "$CONFIG_FILE" ]; then
    echo "Updating worker-runner-config.yaml with new hostname..."
    sudo sed -i.bak "s/workerID: .*/workerID: \"$HOSTNAME\"/" "$CONFIG_FILE"
    sudo sed -i.bak "s/workerId: .*/workerId: \"$HOSTNAME\"/" "$CONFIG_FILE"
    echo "Updated workerID and workerId in $CONFIG_FILE"
else
    echo "WARNING: $CONFIG_FILE not found. Skipping update."
fi

echo "Hostname update complete!"