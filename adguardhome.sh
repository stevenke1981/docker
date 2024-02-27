#!/bin/bash

set -euo pipefail  # Enable error handling for robustness

# Ensure root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script requires root privileges. Please run with sudo."
  exit 1
fi

# Check if systemd-resolved is running
if ! systemctl is-active systemd-resolved; then
  echo "systemd-resolved is not running. Script execution stopped."
  exit 0
fi

# Configure systemd-resolved for AdGuard Home
cat <<EOF > /etc/systemd/resolved.conf.d/adguardhome.conf
[Resolve]
DNS=127.0.0.1
DNSStubListener=no
EOF

systemctl reload-or-restart systemd-resolved

# Run AdGuard Home in a Docker container with optimization flags
docker run --name adguardhome\
    --restart unless-stopped\
    -v /my/own/workdir:/opt/adguardhome/work\
    -v /my/own/confdir:/opt/adguardhome/conf\
    -p 53:53/tcp -p 53:53/udp\
    -p 3000:3000/tcp\
    -d adguard/adguardhome

echo "AdGuard Home server accessible at: http://$(hostname -I | awk '{print $1}'):3000"

