#!/bin/bash
#version 1.1.0
set -euo   # Enable error handling for robustness

# Ensure root privileges
if [[ $EUID -ne 0 ]]; then
 echo "此腳本需要 root 權限。請使用 sudo 執行。"
 exit 1
fi

# Define constants
WORK_DIR="${HOME}/adguardhome/work"
CONFIG_DIR="${HOME}/adguardhome/config"

# Define function to remove AdGuard Home
function remove_adguardhome() {
 echo "移除 AdGuard Home..."

 # Stop and remove container
 docker stop adguardhome
 docker rm adguardhome

 # Remove configuration files
 rm -f /etc/systemd/resolved.conf.d/adguardhome.conf

 # Remove directories
 rm -rf "$WORK_DIR" "$CONFIG_DIR"

 echo "AdGuard Home 已移除。"
}

# Check if systemd-resolved is running
if ! systemctl is-active systemd-resolved; then
 echo "systemd-resolved 沒有在執行。腳本執行已停止。"
 exit 0
fi

# Configure systemd-resolved for AdGuard Home
if [ ! -f /etc/systemd/resolved.conf.d/adguardhome.conf ]; then
 cat <<EOF > /etc/systemd/resolved.conf.d/adguardhome.conf
[Resolve]
DNS=127.0.0.1
DNSStubListener=no
EOF
fi

systemctl reload-or-restart systemd-resolved

# Display menu and handle user input
while true; do
 echo "** AdGuard Home 安裝和移除工具 **"
 echo "1. 安裝 AdGuard Home"
 echo "2. 移除 AdGuard Home (一鍵)"
 echo "3. 離開"
 read -p "輸入您的選擇： " choice

 case "$choice" in
  1)
   # Ensure directories exist
   if [ ! -d "$WORK_DIR" ]; then
    echo "建立工作目錄：$WORK_DIR"
    mkdir -p "$WORK_DIR"
   fi

   if [ ! -d "$CONFIG_DIR" ]; then
    echo "建立設定檔目錄：$CONFIG_DIR"
    mkdir -p "$CONFIG_DIR"
   fi

   # Run AdGuard Home in a Docker container
   docker run \
    --name adguardhome \
    --restart unless-stopped \
    -v "$WORK_DIR":/opt/adguardhome/work \
    -v "$CONFIG_DIR":/opt/adguardhome/conf \
    -p 53:53/tcp -p 53:53/udp \
    -p 3000:3000/tcp \
    -d adguard/adguardhome

   echo "AdGuard Home 伺服器可於 http://$(hostname -I | awk '{print $1}'):3000 存取"
   break
   ;;
  2)
   remove_adguardhome
   break
   ;;
  3)
   echo "離開..."
   exit 0
   ;;
  *)
   echo "無效的選擇。"
   ;;
 esac
done

