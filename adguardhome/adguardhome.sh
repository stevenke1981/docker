#!/bin/bash
# ver 1.1.3

# 顏色設置
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 定義常數目錄
WORK_DIR="${HOME}/adguardhome/work"
CONFIG_DIR="${HOME}/adguardhome/config"

# Function: 顯示選單
function show_menu() {
  echo -e "${BLUE}** AdGuard Home 安裝和移除工具 **${NC}"
  echo -e "${YELLOW}1. 安裝 AdGuard Home${NC}"
  echo -e "${YELLOW}2. 移除 AdGuard Home${NC}"
  echo -e "${YELLOW}3. 離開${NC}"
  echo -n -e "${GREEN}輸入您的選擇： ${NC}"
}

# Function: 檢查 AdGuard Home 容器狀態
check_adguardhome_status() {
  if docker ps | grep -q "adguardhome"; then
    echo -e "${GREEN}AdGuard Home 容器正在運行。${NC}"
  else
    echo -e "${RED}AdGuard Home 容器未運行。${NC}"
  fi
}

# Function: 安裝 AdGuard Home
function install_adguardhome() {
  echo -e "${GREEN}正在安裝 AdGuard Home...${NC}"

  # 設置 systemd-resolved
  configure_systemd_resolved

  # 確保工作目錄和設定目錄存在
  if [ ! -d "$WORK_DIR" ]; then
    echo -e "${YELLOW}建立工作目錄：$WORK_DIR${NC}"
    mkdir -p "$WORK_DIR"
  fi

  if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${YELLOW}建立設定檔目錄：$CONFIG_DIR${NC}"
    mkdir -p "$CONFIG_DIR"
  fi

  # 啟動 AdGuard Home Docker 容器
  docker run \
    --name adguardhome \
    --restart unless-stopped \
    -v "$WORK_DIR":/opt/adguardhome/work \
    -v "$CONFIG_DIR":/opt/adguardhome/conf \
    -p 53:53/tcp -p 53:53/udp \
    -p 3000:3000/tcp \
    -d adguard/adguardhome

  # 檢查容器狀態
  check_adguardhome_status
  echo -e "${GREEN}AdGuard Home 伺服器可於 http://$(hostname -I | awk '{print $1}'):3000 存取${NC}"
}

# Function: 移除 AdGuard Home
function remove_adguardhome() {
  echo -e "${RED}移除 AdGuard Home...${NC}"

  # 停止並移除容器
  docker stop adguardhome && docker rm adguardhome
  rm /etc/resolv.conf
  mv /etc/resolv.conf.backup /etc/resolv.conf
  rm -rf /etc/systemd/resolved.conf.d
  systemctl restart systemd-resolved

  # 提示用戶是否保留資料夾
  while true; do
    read -p "是否保留工作目錄 (${WORK_DIR}) 和設定檔目錄 (${CONFIG_DIR})？ [y/n] " keep_directories

    case "$keep_directories" in
      y|Y)
        echo -e "${YELLOW}保留資料夾。${NC}"
        break
        ;;
      n|N)
        echo -e "${RED}移除資料夾。${NC}"
        rm -rf "$WORK_DIR" "$CONFIG_DIR"
        break
        ;;
      *)
        echo -e "${RED}無效的輸入。${NC}"
        ;;
    esac
  done

  echo -e "${GREEN}AdGuard Home 已移除。${NC}"
}

# Function: 設置 systemd-resolved
function configure_systemd_resolved() {
  if [ ! -f /etc/systemd/resolved.conf.d/adguardhome.conf ]; then
    mkdir -p /etc/systemd/resolved.conf.d
    echo -e "${YELLOW}建立設定檔 /etc/systemd/resolved.conf.d/adguardhome.conf...${NC}"
    echo '[Resolve]
DNS=127.0.0.1
DNSStubListener=no' | tee /etc/systemd/resolved.conf.d/adguardhome.conf
  fi
  
  mv /etc/resolv.conf /etc/resolv.conf.backup
  ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
  systemctl reload-or-restart systemd-resolved
}

# 主程式循環
while true; do
  show_menu
  read -r choice

  case "$choice" in
    1)
      install_adguardhome
      ;;
    2)
      remove_adguardhome
      ;;
    3)
      echo -e "${BLUE}離開...${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}無效的選擇。${NC}"
      ;;
  esac
done
