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
    echo -e "${GREEN}  Samba Server 管理選單  ${NC}"
    echo -e "${BLUE}==============================${NC}"
    echo -e "${YELLOW}1) 安裝 Docker${NC}"
    echo -e "${YELLOW}2) 創建 Samba 環境${NC}"
    echo -e "${YELLOW}3) 啟動 Samba 伺服器${NC}"
    echo -e "${YELLOW}4) 停止 Samba 伺服器${NC}"
    echo -e "${YELLOW}5) 移除 Samba 伺服器${NC}"
    echo -e "${YELLOW}6) 退出${NC}"
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

    # 创建 Docker Compose 配置文件
    cat <<EOF > smbserver/compose.yml
version: '3.7'

services:
  samba:
    image: crazymax/samba:latest
    container_name: samba
    environment:
      - SAMBA_USER=foo  # Samba 使用者
      - SAMBA_PASSWORD=bar  # Samba 使用者的密碼
      - SAMBA_SHARE_NAME=share  # 共享名稱
      - SAMBA_SHARE_PATH=/samba/share  # 共享路徑
      - SAMBA_SHARE_ALLOW=*  # 共享允許的用戶
    volumes:
      - ./data:/data  # 將主機的 ./data 目錄掛載到容器的 /data 目錄
    ports:
      - "137:137/udp"  # UDP 137 端口
      - "138:138/udp"  # UDP 138 端口
      - "139:139"  # TCP 139 端口
      - "445:445"  # TCP 445 端口
    networks:
      - smb_network  # 使用 smb_network 網絡

networks:
  smb_network:  # 定義 smb_network 網絡
    driver: bridge
EOF

    # 创建 Samba 配置文件
    cat <<EOF > smbserver/data/config.yml
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

    echo -e "${GREEN}Samba 環境創建完成！${NC}"
}

# 啟動 Samba 伺服器
function start_samba_server() {
    echo -e "${GREEN}正在啟動 Samba 伺服器...${NC}"
    cd smbserver
    docker-compose up -d
    echo -e "${GREEN}Samba 伺服器已啟動！${NC}"
}

# 停止 Samba 伺服器
function stop_samba_server() {
    echo -e "${GREEN}正在停止 Samba 伺服器...${NC}"
    cd smbserver
    docker-compose down
    echo -e "${GREEN}Samba 伺服器已停止！${NC}"
}

# 移除 Samba 伺服器
function remove_samba_server() {
    if [ -d "smbserver" ]; then
        echo -e "${GREEN}正在移除 Samba 伺服器...${NC}"
        cd smbserver
        docker-compose down
        sudo rm -rf data
        sudo rm -f compose.yml
        sudo rm -f data/config.yml
        echo -e "${GREEN}Samba 伺服器已移除！${NC}"
    else
        echo -e "${RED}smbserver 目錄不存在，無法移除！${NC}"
    fi
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
            stop_samba_server
            ;;
        5)
            remove_samba_server
            ;;
        6)
            echo -e "${GREEN}退出安裝腳本...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}無效的選項，請重試！${NC}"
            ;;
    esac
    echo
done
