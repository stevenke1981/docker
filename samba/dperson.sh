#!/bin/bash
# ver1.2.1

# 顏色設置
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 使用者設置
USER1="example1"
PASSWORD1="badpass"
USER2="example2"
PASSWORD2="badpass"

# 共享目錄設置
SAMBA_BASE_DIR="${HOME}/samba"
SAMBA_PUBLIC_DIR="${SAMBA_BASE_DIR}/public"
SAMBA_USERS_DIR="${SAMBA_BASE_DIR}/srv"
SAMBA_USER1_PRIVATE_DIR="${SAMBA_BASE_DIR}/example1"
SAMBA_USER2_PRIVATE_DIR="${SAMBA_BASE_DIR}/example2"

# Function: 顯示選單
function show_menu() {
  echo -e "${BLUE}** Samba Docker 安裝和移除工具 **${NC}"
  echo -e "${YELLOW}1. 安裝 Samba${NC}"
  echo -e "${YELLOW}2. 移除 Samba${NC}"
  echo -e "${YELLOW}3. 離開${NC}"
  echo -n -e "${GREEN}輸入您的選擇： ${NC}"
}

# Function: 檢查 Samba 服務狀態
check_samba_status() {
  if docker ps --filter "name=samba" --filter "status=running" | grep -q "samba"; then
    echo -e "${GREEN}Samba 服務正在運行。${NC}"
  else
    echo -e "${RED}Samba 服務未運行。${NC}"
  fi
}

# Function: 安裝 Samba
function install_samba() {
  echo -e "${GREEN}正在安裝 Samba...${NC}"

  # 停止已存在的 Samba 服務
  if docker ps | grep -q "samba"; then
    echo -e "${YELLOW}發現已存在的 Samba 服務，正在移除舊服務...${NC}"
    docker stop samba
    docker rm samba
  fi

  # 確保 Samba 共享目錄存在
  mkdir -p "$SAMBA_PUBLIC_DIR" "$SAMBA_USERS_DIR" "$SAMBA_USER1_PRIVATE_DIR" "$SAMBA_USER2_PRIVATE_DIR"

  # 啟動 Samba 容器
  sudo docker run -it -d \
    --name samba \
    -m 512m \
    -p 139:139 -p 445:445 \
    dperson/samba -p \
    -n yes \
    -v "${SAMBA_BASE_DIR}":/share \
    -u "${USER1};${PASSWORD1}" \
    -u "${USER2};${PASSWORD2}" \
    -s "public;${SAMBA_PUBLIC_DIR}" \
    -s "users;${SAMBA_USERS_DIR};no;no;no;${USER1},${USER2}" \
    -s "${USER1} private share;${SAMBA_USER1_PRIVATE_DIR};no;no;no;${USER1}" \
    -s "${USER2} private share;${SAMBA_USER2_PRIVATE_DIR};no;no;no;${USER2}" 

  # 檢查服務狀態
  check_samba_status
  echo -e "${GREEN}Samba 伺服器已安裝完成。${NC}"
}

# Function: 移除 Samba
function remove_samba() {
  echo -e "${RED}移除 Samba...${NC}"

  # 停止並移除 Samba 服務
  docker stop samba
  docker rm samba

  # 提示用戶是否保留資料夾
  while true; do
    read -p "是否保留資料目錄 (${SAMBA_BASE_DIR})？ [y/n] " keep_directories

    case "$keep_directories" in
      y|Y)
        echo -e "${YELLOW}保留資料夾。${NC}"
        break
        ;;
      n|N)
        echo -e "${RED}移除資料夾。${NC}"
        sudo rm -rf "${SAMBA_BASE_DIR}"
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
