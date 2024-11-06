#!/bin/bash
# ver1.1.1

# 顏色設置
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 定義目錄
SAMBA_DATA_DIR="${HOME}/samba/data"
SAMBA_PUBLIC_DIR="${HOME}/samba/public"
SAMBA_SHARE_DIR="${HOME}/samba/share"
SAMBA_FOO_DIR="${HOME}/samba/foo"
SAMBA_FOO_BAZ_DIR="${HOME}/samba/foo-baz"

# Function: 顯示選單
function show_menu() {
  echo -e "${BLUE}** Samba 安裝和移除工具 **${NC}"
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

# Function: 建立 docker-compose.yml 文件
function create_compose_file() {
  cat <<EOF > "${HOME}/samba/docker-compose.yml"
services:
  samba:
    image: crazymax/samba
    container_name: samba
    hostname: docker_samba
    network_mode: host
    cap_add:
      - CAP_NET_ADMIN
      - CAP_NET_RAW
    volumes:
      - "${SAMBA_DATA_DIR}:/data"
      - "${SAMBA_PUBLIC_DIR}:/samba/public"
      - "${SAMBA_SHARE_DIR}:/samba/share"
      - "${SAMBA_FOO_DIR}:/samba/foo"
      - "${SAMBA_FOO_BAZ_DIR}:/samba/foo-baz"
    environment:
      - TZ=Europe/Paris
      - SAMBA_LOG_LEVEL=0
      - WSDD2_ENABLE=1
      - WSDD2_NETBIOS_NAME=docker_samba
    restart: always
EOF
  echo -e "${GREEN}docker-compose.yml 文件已建立於 ${HOME}/samba/docker-compose.yml。${NC}"
}

# Function: 建立 config.yml 檔案
function create_config_file() {
  cat <<EOF > "${SAMBA_DATA_DIR}/config.yml"
auth:
  - user: foo
    group: foo
    uid: 1000
    gid: 1000
    password: bar
  - user: baz
    group: xxx
    uid: 1100
    gid: 1200
    password_file: /run/secrets/baz_password

global:
  - "force user = foo"
  - "force group = foo"

share:
  - name: public
    comment: Public
    path: /samba/public
    browsable: yes
    readonly: yes
    guestok: yes
    veto: no
    recycle: yes
  - name: share
    path: /samba/share
    browsable: yes
    readonly: no
    guestok: yes
    writelist: foo
    veto: no
  - name: foo
    path: /samba/foo
    browsable: yes
    readonly: no
    guestok: no
    validusers: foo
    writelist: foo
    veto: no
    hidefiles: /_*/
  - name: foo-baz
    path: /samba/foo-baz
    browsable: yes
    readonly: no
    guestok: no
    validusers: foo,baz
    writelist: foo,baz
    veto: no
EOF
  echo -e "${GREEN}config.yml 文件已建立於 ${SAMBA_DATA_DIR}/config.yml。${NC}"
}

# Function: 安裝 Samba
function install_samba() {
  echo -e "${GREEN}正在安裝 Samba...${NC}"

  # 停止已存在的 Samba 服務
  if docker ps | grep -q "samba"; then
    echo -e "${YELLOW}發現已存在的 Samba 服務，正在移除舊服務...${NC}"
    docker compose -f "${HOME}/samba/docker-compose.yml" down
  fi

  # 確保 Samba 數據和目錄存在
  mkdir -p "$SAMBA_DATA_DIR" "$SAMBA_PUBLIC_DIR" "$SAMBA_SHARE_DIR" "$SAMBA_FOO_DIR" "$SAMBA_FOO_BAZ_DIR"

  # 建立配置文件
  create_compose_file
  create_config_file

  # 啟動 Samba 服務
  docker compose -f "${HOME}/samba/docker-compose.yml" up -d

  # 檢查服務狀態
  check_samba_status
  echo -e "${GREEN}Samba 伺服器已安裝完成。${NC}"
}

# Function: 移除 Samba
function remove_samba() {
  echo -e "${RED}移除 Samba...${NC}"

  # 停止並移除 Samba 服務
  docker compose -f "${HOME}/samba/docker-compose.yml" down

  # 提示用戶是否保留資料夾
  while true; do
    read -p "是否保留資料目錄 (${HOME}/samba)？ [y/n] " keep_directories

    case "$keep_directories" in
      y|Y)
        echo -e "${YELLOW}保留資料夾。${NC}"
        break
        ;;
      n|N)
        echo -e "${RED}移除資料夾。${NC}"
        sudo rm -rf "${HOME}/samba"
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
