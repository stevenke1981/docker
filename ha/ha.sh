#!/bin/bash

#ver 1.0.0

# Function: Show the menu
function show_menu() {
  echo "----------------------------------------"
  echo "HomeAssist 安裝/移除 腳本"
  echo "----------------------------------------"
  echo "1. 安裝 HomeAssist"
  echo "2. 移除 HomeAssist"
  echo "0. 退出"
  echo "----------------------------------------"
  echo -n "請輸入您的選擇： "
}

# Function: Install HomeAssistant
function install_homeassistant() {
  echo "正在安裝 HomeAssist..."

  # Check if Docker is installed
 # if ! command -v docker &> /dev/null; then
 #   echo "正在安裝 Docker..."
 #   sudo apt update && sudo apt install -y docker.io
 # fi

  # Create HomeAssistant directories
  mkdir -p "$HOME/homeassistant/config"

  # 設定 Home Assistant 安裝目錄
# home_dir=$HOME/homeassistant/config

# 建立必要的目錄
config_dir="$HOME/homeassistant/config"
hacs_dir="$config_dir/custom_components/hacs"
mkdir -p "$hacs_dir"

# 下載 HACS zip 檔案
hacs_zip_url="https://github.com/hacs/integration/releases/download/1.34.0/hacs.zip"
hacs_zip_path="$hacs_dir/hacs.zip"
echo "正在下載 HACS..."
wget "$hacs_zip_url" -O "$hacs_zip_path"

# 解壓縮 HACS zip 檔案
echo "正在解壓縮 HACS..."
unzip "$hacs_zip_path" -d "$hacs_dir"

# 清理
rm "$hacs_zip_path"

echo "HACS 安裝成功！"


  # Start HomeAssistant container (remove newline character for clarity)
  docker run -d --name homeassistant --privileged --restart unless-stopped \
    -p 8123:8123/tcp -e TZ=Asia/Taipei -v "$HOME/homeassistant/config:/config" --network host homeassistant/home-assistant:stable
  echo "HomeAssist 安裝完成。"
  echo "HomeAssist accessible at: http://$(hostname -I | awk '{print $1}'):8123"
}

# Function: Remove HomeAssistant
function remove_homeassistant() {
  echo "正在移除 HomeAssist..."

  # Stop and remove HomeAssistant container
  docker stop homeassistant && docker rm homeassistant

  # Remove HomeAssistant directories
  rm -rf "$HOME/homeassistant"
  echo "HomeAssist 移除完成。"
}

# Main program loop
while true; do
  show_menu
  read choice

  case $choice in
    1)
      install_homeassistant
      ;;
    2)
      remove_homeassistant
      ;;
    0)
      echo "結束程式。"
      exit 0
      ;;
    *)
      echo "無效的選擇。"
      ;;
  esac
done
