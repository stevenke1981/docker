#!/bin/bash
# ver1.1.1

# 顏色設置
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Pi-hole 設置
PIHOLE_CONTAINER_NAME="pihole"
PIHOLE_IMAGE="pihole/pihole:latest"
PIHOLE_ETC_DIR="${HOME}/pihole/etc-pihole"
PIHOLE_DNSMASQ_DIR="${HOME}/pihole/etc-dnsmasq.d"
PIHOLE_TIMEZONE="America/Chicago"
PIHOLE_WEBPASSWORD="your_secure_password"

# Function: 顯示選單
function show_menu() {
  echo -e "${BLUE}** Pi-hole Docker 安裝和移除工具 **${NC}"
  echo -e "${YELLOW}1. 安裝 Pi-hole${NC}"
  echo -e "${YELLOW}2. 移除 Pi-hole${NC}"
  echo -e "${YELLOW}3. 離開${NC}"
  echo -n -e "${GREEN}輸入您的選擇： ${NC}"
}

# Function: 檢查端口 53 衝突並釋放
function check_and_free_port_53() {
  if sudo lsof -i :53 | grep -q "systemd-resolve"; then
    echo -e "${YELLOW}檢測到 systemd-resolved 使用 53 端口，正在釋放該端口...${NC}"
    sudo sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved
    echo -e "${GREEN}已釋放 53 端口。${NC}"
  fi
}

# Function: 檢查 Pi-hole 服務狀態
check_pihole_status() {
  if docker ps --filter "name=${PIHOLE_CONTAINER_NAME}" --filter "status=running" | grep -q "${PIHOLE_CONTAINER_NAME}"; then
    echo -e "${GREEN}Pi-hole 服務正在運行。${NC}"
  else
    echo -e "${RED}Pi-hole 服務未運行。${NC}"
  fi
}

# Function: 安裝 Pi-hole
function install_pihole() {
  echo -e "${GREEN}正在安裝 Pi-hole...${NC}"

  # 釋放端口 53
  check_and_free_port_53

  # 停止已存在的 Pi-hole 服務
  if docker ps | grep -q "${PIHOLE_CONTAINER_NAME}"; then
    echo -e "${YELLOW}發現已存在的 Pi-hole 服務，正在移除舊服務...${NC}"
    docker rm -f "${PIHOLE_CONTAINER_NAME}"
  fi

  # 建立配置目錄
  mkdir -p "$PIHOLE_ETC_DIR" "$PIHOLE_DNSMASQ_DIR"

  # 啟動 Pi-hole 容器
  docker run -d \
    --name "${PIHOLE_CONTAINER_NAME}" \
    -p 53:53/tcp -p 53:53/udp -p 67:67/udp -p 80:80/tcp \
    -e TZ="${PIHOLE_TIMEZONE}" \
    -e WEBPASSWORD="${PIHOLE_WEBPASSWORD}" \
    -v "${PIHOLE_ETC_DIR}:/etc/pihole" \
    -v "${PIHOLE_DNSMASQ_DIR}:/etc/dnsmasq.d" \
    --cap-add=NET_ADMIN \
    --restart=unless-stopped \
    "${PIHOLE_IMAGE}"

  # 檢查服務狀態
  check_pihole_status
  echo -e "${GREEN}Pi-hole 伺服器已安裝完成。${NC}"
}

# Function: 移除 Pi-hole
function remove_pihole() {
  echo -e "${RED}移除 Pi-hole...${NC}"

  # 停止並移除 Pi-hole 服務
  docker rm -f "${PIHOLE_CONTAINER_NAME}"

  # 提示用戶是否保留資料夾
  while true; do
    read -p "是否保留資料目錄 (${HOME}/pihole)？ [y/n] " keep_directories

    case "$keep_directories" in
      y|Y)
        echo -e "${YELLOW}保留資料夾。${NC}"
        break
        ;;
      n|N)
        echo -e "${RED}移除資料夾。${NC}"
        sudo rm -rf "${HOME}/pihole"
        break
        ;;
      *)
        echo -e "${RED}無效的輸入。${NC}"
        ;;
    esac
  done

  echo -e "${GREEN}Pi-hole 已移除。${NC}"
}

# 主程式循環
while true; do
  show_menu
  read -r choice

  case "$choice" in
    1)
      install_pihole
      ;;
    2)
      remove_pihole
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
