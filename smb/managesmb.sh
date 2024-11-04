#!/bin/bash

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 檢查是否為 root 用戶
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}請使用 sudo 執行此腳本${NC}"
        exit 1
    fi
}

# 顯示狀態消息
show_status() {
    echo -e "${YELLOW}>>> $1${NC}"
}

# 檢查命令是否成功
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}完成！${NC}"
    else
        echo -e "${RED}失敗！${NC}"
        exit 1
    fi
}

# 檢查 Docker 是否已安裝
check_docker() {
    if command -v docker &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 檢查 Docker Compose 是否已安裝
check_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 安裝 Docker
install_docker() {
    show_status "開始安裝 Docker..."
    curl -fsSL https://get.docker.com | sh
    check_status
    
    show_status "將當前用戶添加到 docker 群組..."
    usermod -aG docker $SUDO_USER
    check_status
    
    show_status "啟動 Docker 服務..."
    systemctl start docker
    systemctl enable docker
    check_status
}

# 安裝 Docker Compose
install_docker_compose() {
    show_status "開始安裝 Docker Compose..."
    
    # 安裝依賴
    apt-get update
    apt-get install -y curl
    
    # 下載最新版的 Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    check_status
    
    show_status "設置執行權限..."
    chmod +x /usr/local/bin/docker-compose
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    check_status
}

# 創建 Web+SMB 服務
setup_web_smb() {
    local INSTALL_DIR="/opt/docker/web-smb"
    show_status "創建安裝目錄..."
    mkdir -p $INSTALL_DIR
    
    # 創建 docker-compose.yml
    cat > $INSTALL_DIR/docker-compose.yml << 'EOF'
version: '3'
services:
  nginx:
    image: nginx:alpine
    container_name: web_server
    ports:
      - "80:80"
    volumes:
      - website_data:/usr/share/nginx/html
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - samba
    restart: unless-stopped

  samba:
    image: dperson/samba
    container_name: smb_server
    ports:
      - "445:445"
      - "139:139"
      - "137:137/udp"
      - "138:138/udp"
    volumes:
      - website_data:/share
    environment:
      - TZ=Asia/Taipei
      - USERID=1000
      - GROUPID=1000
    command: '-s "website;/share;yes;no;yes;all;none;none" -u "webadmin;password"'
    restart: unless-stopped

volumes:
  website_data:
EOF

    # 創建 nginx.conf
    cat > $INSTALL_DIR/nginx.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    
    root /usr/share/nginx/html;
    index index.html index.htm;
    
    location / {
        try_files $uri $uri/ =404;
        autoindex on;
    }
}
EOF

    # 設置權限
    chown -R $SUDO_USER:$SUDO_USER $INSTALL_DIR
    
    show_status "服務文件已創建在 $INSTALL_DIR"
    show_status "您可以通過以下命令啟動服務："
    echo "cd $INSTALL_DIR"
    echo "docker-compose up -d"
}

# 主選單
show_menu() {
    clear
    echo "==================================="
    echo "    Docker 安裝和配置助手"
    echo "==================================="
    echo "1. 安裝 Docker"
    echo "2. 安裝 Docker Compose"
    echo "3. 創建 Web+SMB 服務"
    echo "4. 安裝所有組件"
    echo "5. 退出"
    echo "==================================="
}

# 主程序
main() {
    check_root
    
    while true; do
        show_menu
        read -p "請選擇操作 [1-5]: " choice
        
        case $choice in
            1)
                if check_docker; then
                    echo -e "${YELLOW}Docker 已安裝！${NC}"
                else
                    install_docker
                fi
                read -p "按 Enter 鍵繼續..."
                ;;
            2)
                if check_docker_compose; then
                    echo -e "${YELLOW}Docker Compose 已安裝！${NC}"
                else
                    install_docker_compose
                fi
                read -p "按 Enter 鍵繼續..."
                ;;
            3)
                if ! check_docker || ! check_docker_compose; then
                    echo -e "${RED}請先安裝 Docker 和 Docker Compose！${NC}"
                else
                    setup_web_smb
                fi
                read -p "按 Enter 鍵繼續..."
                ;;
            4)
                if ! check_docker; then
                    install_docker
                fi
                if ! check_docker_compose; then
                    install_docker_compose
                fi
                setup_web_smb
                read -p "按 Enter 鍵繼續..."
                ;;
            5)
                echo "感謝使用！"
                exit 0
                ;;
            *)
                echo -e "${RED}無效的選擇！${NC}"
                read -p "按 Enter 鍵繼續..."
                ;;
        esac
    done
}

# 執行主程序
main
