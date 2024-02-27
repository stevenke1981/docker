#!/bin/bash

set -euo pipefail  # Enable error handling for robustness

# Ensure root privileges
if [[ $EUID -ne 0 ]]; then
  echo "此腳本需要 root 權限。請使用 sudo 執行。"
  exit 1
fi

# Check if systemd-resolved is running
if ! systemctl is-active systemd-resolved; then
  echo "systemd-resolved 沒有在執行。腳本執行已停止。"
  exit 0
fi

# Define function to remove AdGuard Home
function remove_adguardhome() {
  echo "移除 AdGuard Home..."

  # Stop and remove container
  docker stop adguardhome
  docker rm adguardhome

  # Remove configuration files
  rm -f /etc/systemd/resolved.conf.d/adguardhome.conf

  # Remove directories
  rm -rf "$work_dir" "$config_dir"

  echo "AdGuard Home 已移除。"
}

# Configure systemd-resolved for AdGuard Home
cat <<EOF > /etc/systemd/resolved.conf.d/adguardhome.conf
[Resolve]
DNS=127.0.0.1
DNSStubListener=no
EOF

systemctl reload-or-restart systemd-resolved

# 設定工作目錄和設定檔目錄
work_dir="~/adguardhome/work"
config_dir="~/adguardhome/config"

# 檢查目錄是否存在
if [ ! -d "$work_dir" ]; then
  echo "建立工作目錄：$work_dir"
  mkdir -p "$work_dir"
fi

if [ ! -d "$config_dir" ]; then
  echo "建立設定檔目錄：$config_dir"
  mkdir -p "$config_dir"
fi

# 顯示選單
echo "** AdGuard Home 安裝和移除工具 **"
echo "1. 安裝 AdGuard Home"
echo "2. 移除 AdGuard Home (一鍵)"
echo "3. 離開"
read -p "輸入您的選擇： " choice

# 處理使用者輸入
case "$choice" in
  1)
    # Run AdGuard Home in a Docker container with optimization flags
    docker run \
      --name adguardhome \
      --restart unless-stopped \
      -v "$work_dir":/opt/adguardhome/work \
      -v "$config_dir":/opt/adguardhome/conf \
      -p 53:53/tcp -p 53:53/udp \
      -p 3000:3000/tcp \
      -d adguard/adguardhome

    echo "AdGuard Home 伺服器可於 http://$(hostname -I | awk '{print $1}'):3000 存取"
    ;;
  2)
    remove_adguardhome
    ;;
  3)
    echo "離開..."
    exit 0
    ;;
  *)
    echo "無效的選擇。"
    ;;
esac
