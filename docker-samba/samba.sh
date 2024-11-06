#!/bin/bash
# ver 1.0.0

# 顏色設置
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 定義常數目錄
SAMBA_DATA_DIR="${HOME}/samba/data"
SAMBA_CONFIG_DIR="${HOME}/samba/config"

# Function: 顯示選單
function show_menu() {
  echo -e "${BLUE}** Samba 安裝和移除工具 **${NC}"
  echo -e "${YELLOW}1. 安裝 Samba${NC}"
  echo -e "${YELLOW}2. 移除 Samba${NC}"
  echo -e "${YELLOW}3. 離開${NC}"
  echo -n -e "${GREEN}輸入您的選擇： ${NC}"
}

# Function: 檢查 Samba 容器狀態
check_samba_status() {
  if docker ps | grep -q "samba"; then
    echo -e "${GREEN}Samba 容器正在運行。${NC}"
  else
    echo -e "${RED}Samba 容器未運行。${NC}"
  fi
}

# Function: 安裝 Samba
function install_samba() {
  echo -e "${GREEN}正在安裝 Samba...${NC}"

  # 檢查是否已有 samba 容器存在
  if docker ps -a --format '{{.Names}}' | grep -q "^samba$"; then
    echo -e "${YELLOW}發現已存在的 Samba 容器，正在移除舊容器...${NC}"
    docker stop samba && docker rm samba
  fi

  # 確保 Samba 數據和設定目錄存在
  if [ ! -d "$SAMBA_DATA_DIR" ]; then
    echo -e "${YELLOW}建立數據目錄：$SAMBA_DATA_DIR${NC}"
    mkdir -p "$SAMBA_DATA_DIR"
  fi

  if [ ! -d "$SAMBA_CONFIG_DIR" ]; then
    echo -e "${YELLOW}建立設定目錄：$SAMBA_CONFIG_DIR${NC}"
    mkdir -p "$SAMBA_CONFIG_DIR"
  fi

  # 啟動 Samba Docker 容器
  docker run -d --name samba \
    -p 137:137/udp -p 138:138/udp -p 139:139 -p 445:445 \
    -v "$SAMBA_DATA_DIR":/mount/data \
    -v "$SAMBA_CONFIG_DIR":/etc/samba \
    crazymax/samba

  # 檢查容器狀態
  check_samba_status
  echo -e "${GREEN}Samba 伺服器已安裝完成。${NC}"
}

# Function: 移除 Samba
function remove_samba() {
  echo -e "${RED}移除 Samba...${NC}"

  # 停止並移除容器
  docker stop samba && docker rm samba

  # 提示用戶是否保留資料夾
  while true; do
    read -p "是否保留數據目錄 (${SAMBA_DATA_DIR}) 和設定目錄 (${SAMBA_CONFIG_DIR})？ [y/n] " keep_directories

    case "$keep_directories" in
      y|Y)
        echo -e "${YELLOW}保留資料夾。${NC}"
        break
        ;;
      n|N)
        echo -e "${RED}移除資料夾。${NC}"
        rm -rf "$SAMBA_DATA_DIR" "$SAMBA_CONFIG_DIR"
        break
        ;;
      *)
        echo -e "${RED}無效的輸入。${NC}"
        ;;
    esac
  done

  echo -e "${GREEN}Samba 已移除。${NC}"
}

# 主程式循環
while true; do
  show_menu
  read -r choice

  case "$choice" in
    1)
      install_samba
      ;;
    2)
      remove_samba
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
