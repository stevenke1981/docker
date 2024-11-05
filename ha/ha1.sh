#!/bin/bash

# ver 1.0.0

# 顏色設置
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# HomeAssistant 目錄設定
config_dir="$HOME/homeassistant/config"
hacs_dir="$config_dir/custom_components/hacs"
hacs_zip_url="https://github.com/hacs/integration/releases/download/1.34.0/hacs.zip"
hacs_zip_path="$hacs_dir/hacs.zip"

# Function: Show the menu
function show_menu() {
  echo -e "${BLUE}----------------------------------------${NC}"
  echo -e "${YELLOW}HomeAssist 安裝/移除 腳本${NC}"
  echo -e "${BLUE}----------------------------------------${NC}"
  echo -e "${GREEN}1. 安裝 HomeAssist${NC}"
  echo -e "${GREEN}2. 移除 HomeAssist${NC}"
  echo -e "${GREEN}0. 退出${NC}"
  echo -e "${BLUE}----------------------------------------${NC}"
  echo -n -e "${GREEN}請輸入您的選擇： ${NC}"
}

# 檢查 HomeAssistant 容器狀態
check_homeassistant_status() {
  if docker ps | grep -q "homeassistant"; then
    echo -e "${GREEN}HomeAssist 容器正在運行。${NC}"
  else
    echo -e "${RED}HomeAssist 容器未運行。${NC}"
  fi
}

# Function: Install HomeAssistant
function install_homeassistant() {
  echo -e "${GREEN}正在安裝 HomeAssist...${NC}"

  # 建立 HomeAssistant 和 HACS 目錄
  mkdir -p "$config_dir" "$hacs_dir"

  # 下載 HACS zip 檔案
  echo -e "${YELLOW}正在下載 HACS...${NC}"
  wget "$hacs_zip_url" -O "$hacs_zip_path"

  # 解壓縮 HACS zip 檔案
  echo -e "${YELLOW}正在解壓縮 HACS...${NC}"
  unzip "$hacs_zip_path" -d "$hacs_dir"

  # 清理
  rm "$hacs_zip_path"
  echo -e "${GREEN}HACS 安裝成功！${NC}"

  # 啟動 HomeAssistant 容器
  docker run -d --name homeassistant --privileged --restart unless-stopped \
    -p 8123:8123/tcp -e TZ=Asia/Taipei -v "$config_dir:/config" \
    --network host homeassistant/home-assistant:stable

  # 檢查容器狀態
  check_homeassistant_status
  echo -e "${GREEN}HomeAssist 安裝完成。${NC}"
  echo -e "${BLUE}HomeAssist accessible at: http://$(hostname -I | awk '{print $1}'):8123${NC}"
}

# Function: Remove HomeAssistant
function remove_homeassistant() {
  echo -e "${RED}正在移除 HomeAssist...${NC}"

  # 停止並移除 HomeAssistant 容器
  docker stop homeassistant && docker rm homeassistant

  # 移除 HomeAssistant 目錄
  rm -rf "$HOME/homeassistant"
  
  # 檢查容器狀態
  check_homeassistant_status
  echo -e "${GREEN}HomeAssist 移除完成。${NC}"
}

# Main program loop
while true; do
  show_menu
  read -r choice

  case $choice in
    1)
      install_homeassistant
      ;;
    2)
      remove_homeassistant
      ;;
    0)
      echo -e "${BLUE}結束程式。${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}無效的選擇。${NC}"
      ;;
  esac
done
