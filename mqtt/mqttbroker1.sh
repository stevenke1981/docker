#!/bin/bash

# 顏色設置
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Docker Mosquitto 配置
MOSQUITTO_CONTAINER="mosquitto"
MOSQUITTO_PORT="1883"
MOSQUITTO_DIR="$HOME/mosquitto"
MOSQUITTO_CONFIG_DIR="$HOME/mosquitto/config"
MOSQUITTO_DATA_DIR="$HOME/mosquitto/data"
MOSQUITTO_LOG_DIR="$HOME/mosquitto/log"

# 顯示選單
show_menu() {
  echo -e "${BLUE}==== Eclipse Mosquitto 安裝腳本 ====${NC}"
  echo -e "${YELLOW}1. 安裝 Mosquitto Docker 容器${NC}"
  echo -e "${YELLOW}2. 移除 Mosquitto Docker 容器${NC}"
  echo -e "${YELLOW}3. 退出${NC}"
  echo -n -e "${GREEN}請選擇選項: ${NC}"
}

# 檢查容器狀態
check_mosquitto_status() {
  if docker ps | grep -q "$MOSQUITTO_CONTAINER"; then
    echo -e "${GREEN}Mosquitto 容器正在運行。${NC}"
  else
    echo -e "${RED}Mosquitto 容器未運行。${NC}"
  fi
}

# 安裝 Mosquitto 容器
install_mosquitto() {
  echo -e "${GREEN}正在安裝 Mosquitto Docker 容器...${NC}"
  
  # 建立配置資料夾
  mkdir -p "$MOSQUITTO_CONFIG_DIR" "$MOSQUITTO_DATA_DIR" "$MOSQUITTO_LOG_DIR"
  
  # 建立 Mosquitto 配置檔案
  if [ ! -f "$MOSQUITTO_CONFIG_DIR/mosquitto.conf" ]; then
    cat <<EOL > "$MOSQUITTO_CONFIG_DIR/mosquitto.conf"
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
allow_anonymous true
listener $MOSQUITTO_PORT
EOL
    echo -e "${YELLOW}已生成默認配置文件${NC}"
  fi

  # 啟動容器
  docker run -d --name "$MOSQUITTO_CONTAINER" -p "$MOSQUITTO_PORT:$MOSQUITTO_PORT" \
    -v "$MOSQUITTO_CONFIG_DIR:/mosquitto/config" \
    -v "$MOSQUITTO_DATA_DIR:/mosquitto/data" \
    -v "$MOSQUITTO_LOG_DIR:/mosquitto/log" \
    eclipse-mosquitto

  # 檢查容器狀態
  check_mosquitto_status
}

# 移除 Mosquitto 容器
remove_mosquitto() {
  echo -e "${RED}正在移除 Mosquitto Docker 容器...${NC}"
  docker stop "$MOSQUITTO_CONTAINER" && docker rm "$MOSQUITTO_CONTAINER"
  
  # 檢查容器狀態
  check_mosquitto_status

  #移除MOSQUITTO資料夾
  rm -rf "$MOSQUITTO_DIR"
}

# 主程式循環
while true; do
  show_menu
  read -r choice
  case $choice in
    1)
      install_mosquitto
      ;;
    2)
      remove_mosquitto
      ;;
    3)
      echo -e "${BLUE}退出腳本。${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}無效選項，請重新選擇。${NC}"
      ;;
  esac
done
