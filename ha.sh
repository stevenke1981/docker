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
  mkdir -p "$HOME/homeassistant/config" "$HOME/homeassistant/addone"

  # Start HomeAssistant container (remove newline character for clarity)
  docker run -d --name homeassistant --privileged --restart unless-stopped \
    -e TZ=Asia/Taipei -v "$HOME/homeassistant/config:/config" --network host homeassistant/home-assistant:stable
  echo "HomeAssist 安裝完成。"
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
