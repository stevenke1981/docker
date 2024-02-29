#!/bin/bash
#ver1.1.2

# Define constants
WORK_DIR="${HOME}/adguardhome/work"
CONFIG_DIR="${HOME}/adguardhome/config"

# Define function to install AdGuard Home
function install_adguardhome() {
  # Configure systemd-resolved
  configure_systemd_resolved

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
}

# Define function to remove AdGuard Home
function remove_adguardhome() {
  echo "移除 AdGuard Home..."

  # Stop and remove container
  docker stop adguardhome
  docker rm adguardhome
  rm /etc/resolv.conf
  mv /etc/resolv.conf.backup /etc/resolv.conf
  sudo rm -rf /etc/systemd/resolved.conf.d
  systemctl restart systemd-resolved

  # Prompt user to keep or remove directories
  while true; do
    read -p "是否保留工作目錄 (${WORK_DIR}) 和設定檔目錄 (${CONFIG_DIR})？ [y/n] " keep_directories

    case "$keep_directories" in
      y|Y)
        echo "保留資料夾。"
        break
        ;;
      n|N)
        echo "移除資料夾。"
        rm -rf "$WORK_DIR" "$CONFIG_DIR"
        break
        ;;
      *)
        echo "無效的輸入。"
        ;;
    esac
  done

  echo "AdGuard Home 已移除。"
}

# Define function to configure systemd-resolved
function configure_systemd_resolved() {
  if [ ! -f /etc/systemd/resolved.conf.d/adguardhome.conf ]; then
    sudo mkdir -p /etc/systemd/resolved.conf.d
    echo "建立設定檔 /etc/systemd/resolved.conf.d/adguardhome.conf..."
    echo '[Resolve]
DNS=127.0.0.1
DNSStubListener=no' | sudo tee /etc/systemd/resolved.conf.d/adguardhome.conf
  fi
  
  mv /etc/resolv.conf /etc/resolv.conf.backup
  ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
  systemctl reload-or-restart systemd-resolved
}

# Display menu and handle user input
while true; do
  echo "** AdGuard Home 安裝和移除工具 **"
  echo "1. 安裝 AdGuard Home"
  echo "2. 移除 AdGuard Home"
  echo "3. 離開"
  read -p "輸入您的選擇： " choice

  case "$choice" in
    1)
      install_adguardhome
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
