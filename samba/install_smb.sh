#!/bin/bash

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 無顏色

# 顯示選單
function show_menu() {
    echo -e "${BLUE}==============================${NC}"
    echo -e "${GREEN}  Samba Server 安裝選單  ${NC}"
    echo -e "${BLUE}==============================${NC}"
    echo -e "${YELLOW}1) 安裝 Docker${NC}"
    echo -e "${YELLOW}2) 創建 Samba 環境${NC}"
    echo -e "${YELLOW}3) 啟動 Samba 伺服器${NC}"
    echo -e "${YELLOW}4) 退出${NC}"
    echo -e "${BLUE}==============================${NC}"
}

# 安裝 Docker
function install_docker() {
    echo -e "${GREEN}正在安裝 Docker...${NC}"
    sudo apt-get update
    sudo apt-get install -y docker.io docker-compose
    echo -e "${GREEN}Docker 安裝完成！${NC}"
}

# 創建 Samba 環境
function create_samba_environment() {
    echo -e "${GREEN}正在創建 Samba 環境...${NC}"
    mkdir -p smbserver/data
    cat <<EOF > smbserver/compose.yml
version: '3.7'

services:
  samba:
    image: crazymax/samba:latest
    container_name: samba
    environment:
      - SAMBA_USER=user
      - SAMBA_PASSWORD=pass
      - SAMBA_SHARE_NAME=share
      - SAMBA_SHARE_PATH=/data
      - SAMBA_SHARE_ALLOW=*
    volumes:
      - ./data:/data
    ports:
      - "137:137/udp"
      - "138:138/udp"
      - "139:139"
      - "445:445"
    networks:
      - smb_network

networks:
  smb_network:
    driver: bridge
EOF
    cat <<EOF > smbserver/data/config.yml
smb:
  shares:
    share:
      path: /data
      comment: "Samba Share"
      read_only: false
      guest_ok: yes
EOF
    echo -e "${GREEN}Samba 環境創建完成！${NC}"
}

# 啟動 Samba 伺服器
function start_samba_server() {
    echo -e "${GREEN}正在啟動 Samba 伺服器...${NC}"
    cd smbserver
    docker-compose up -d
    echo -e "${GREEN}Samba 伺服器已啟動！${NC}"
}

# 主循環
while true; do
    show_menu
    read -p "請選擇一個選項: " choice
    case $choice in
        1)
            install_docker
            ;;
        2)
            create_samba_environment
            ;;
        3)
            start_samba_server
            ;;
        4)
            echo -e "${GREEN}退出安裝腳本...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}無效的選項，請重試！${NC}"
            ;;
    esac
    echo
done
