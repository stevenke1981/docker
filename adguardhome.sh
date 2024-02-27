#!/bin/bash

# Ensure script is run with root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script requires root privileges. Please run with sudo."
  exit 1
fi

# Check if systemd-resolved is running
if ! systemctl is-active systemd-resolved; then
  echo "systemd-resolved is not running. Script execution stopped."
  exit 0
fi

# Create the directory if it doesn't exist
mkdir -p /etc/systemd/resolved.conf.d

# Create the adguardhome.conf file with proper indentation
cat <<EOF > /etc/systemd/resolved.conf.d/adguardhome.conf
[Resolve]
DNS=127.0.0.1
DNSStubListener=no
EOF

# Back up the existing resolv.conf file (optional)
cp /etc/resolv.conf /etc/resolv.conf.backup &> /dev/null

# Create a symlink to the systemd-resolved managed resolv.conf
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Reload systemd-resolved to apply changes
systemctl reload-or-restart systemd-resolved

echo "DNSStubListener disabled and resolv.conf updated for AdGuardHome."
