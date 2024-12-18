#!/bin/bash
# ver 1.1.0
# 顏色設置
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# HomeAssistant 目錄設定
config_dir="$HOME/homeassistant/config"
hacs_dir="$config_dir/custom_components/hacs"
hacs_zip_url="https://github.com/hacs/integration/releases/download/2.0.1/hacs.zip"
hacs_zip_path="$hacs_dir/hacs.zip"

# Function: Show the menu
function show_menu() {
  echo -e "${BLUE}----------------------------------------${NC}"
  echo -e "${YELLOW}HomeAssist 安裝/管理 腳本${NC}"
  echo -e "${BLUE}----------------------------------------${NC}"
  echo -e "${GREEN}1. 安裝 HomeAssist${NC}"
  echo -e "${GREEN}2. 移除 HomeAssist${NC}"
  echo -e "${GREEN}3. 重新啟動 HomeAssist${NC}"
  echo -e "${GREEN}4. 停止 HomeAssist${NC}"
  echo -e "${GREEN}5. 啟動 HomeAssist${NC}"
  echo -e "${GREEN}6. 查看狀態${NC}"
  echo -e "${GREEN}0. 退出${NC}"
  echo -e "${BLUE}----------------------------------------${NC}"
  echo -n -e "${GREEN}請輸入您的選擇： ${NC}"
}

# 檢查 HomeAssistant 容器狀態
check_homeassistant_status() {
  if docker ps | grep -q "homeassistant"; then
    echo -e "${GREEN}HomeAssist 容器正在運行。${NC}"
    echo -e "${GREEN}運行狀態：${NC}"
    docker ps --filter "name=homeassistant" --format "table {{.ID}}\t{{.Status}}\t{{.Ports}}"
  else
    if docker ps -a | grep -q "homeassistant"; then
      echo -e "${YELLOW}HomeAssist 容器已停止。${NC}"
    else
      echo -e "${RED}HomeAssist 容器未安裝。${NC}"
    fi
  fi
}

# Function: Install HomeAssistant
function install_homeassistant() {
  echo -e "${GREEN}正在安裝 HomeAssist...${NC}"
  # 檢查是否已安裝
  if docker ps -a | grep -q "homeassistant"; then
    echo -e "${RED}HomeAssist 已經安裝。如需重新安裝，請先移除舊版本。${NC}"
    return
  fi
  
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
  echo -e "${GREEN}HomeAssist accessible at: http://$(hostname -I | awk '{print $1}'):8123${NC}"
}

# Function: Remove HomeAssistant
function remove_homeassistant() {
  echo -e "${RED}正在移除 HomeAssist...${NC}"
  
  # 確認是否要移除
  echo -n -e "${YELLOW}確定要移除 HomeAssist 嗎？這將刪除所有數據。(y/N): ${NC}"
  read -r confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}取消移除操作。${NC}"
    return
  fi
  
  # 停止並移除 HomeAssistant 容器
  docker stop homeassistant && docker rm homeassistant
  
  # 移除 HomeAssistant 目錄
  sudo rm -rf "$HOME/homeassistant"
  
  # 檢查容器狀態
  check_homeassistant_status
  echo -e "${GREEN}HomeAssist 移除完成。${NC}"
}

# Function: Restart HomeAssistant
function restart_homeassistant() {
  echo -e "${YELLOW}正在重新啟動 HomeAssist...${NC}"
  if ! docker ps -a | grep -q "homeassistant"; then
    echo -e "${RED}HomeAssist 尚未安裝。${NC}"
    return
  fi
  docker restart homeassistant
  echo -e "${GREEN}等待服務重新啟動...${NC}"
  sleep 5
  check_homeassistant_status
}

# Function: Stop HomeAssistant
function stop_homeassistant() {
  echo -e "${YELLOW}正在停止 HomeAssist...${NC}"
  if ! docker ps | grep -q "homeassistant"; then
    echo -e "${RED}HomeAssist 已經停止或尚未安裝。${NC}"
    return
  fi
  docker stop homeassistant
  check_homeassistant_status
}

# Function: Start HomeAssistant
function start_homeassistant() {
  echo -e "${GREEN}正在啟動 HomeAssist...${NC}"
  if ! docker ps -a | grep -q "homeassistant"; then
    echo -e "${RED}HomeAssist 尚未安裝。${NC}"
    return
  fi
  if docker ps | grep -q "homeassistant"; then
    echo -e "${YELLOW}HomeAssist 已經在運行中。${NC}"
    return
  fi
  docker start homeassistant
  echo -e "${GREEN}等待服務啟動...${NC}"
  sleep 5
  check_homeassistant_status
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
    3)
      restart_homeassistant
      ;;
    4)
      stop_homeassistant
      ;;
    5)
      start_homeassistant
      ;;
    6)
      check_homeassistant_status
      ;;
    0)
      echo -e "${BLUE}結束程式。${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}無效的選擇。${NC}"
      ;;
  esac
  
  # 在每個操作後暫停
  echo -e "${YELLOW}按 Enter 鍵繼續...${NC}"
  read -r
done
