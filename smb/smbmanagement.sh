#version 0.1
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

# 停止 Docker 服務
stop_docker() {
    show_status "停止 Docker 服務..."
    systemctl stop docker
    check_status
    
    show_status "禁用 Docker 自動啟動..."
    systemctl disable docker
    check_status
}

# 啟動 Docker 服務
start_docker() {
    show_status "啟動 Docker 服務..."
    systemctl start docker
    check_status
    
    show_status "啟用 Docker 自動啟動..."
    systemctl enable docker
    check_status
}

# 安裝 Docker Compose
install_docker_compose() {
    show_status "開始安裝 Docker Compose..."
    
    apt-get update
    apt-get install -y curl
    
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    check_status
    
    show_status "設置執行權限..."
    chmod +x /usr/local/bin/docker-compose
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    check_status
}

# 管理 Web+SMB 服務
manage_web_smb() {
    local INSTALL_DIR="/opt/docker/web-smb"
    if [ ! -d "$INSTALL_DIR" ]; then
        echo -e "${RED}Web+SMB 服務尚未安裝！${NC}"
        return 1
    fi
    
    cd $INSTALL_DIR
    
    while true; do
        clear
        echo "==================================="
        echo "    Web+SMB 服務管理"
        echo "==================================="
        echo "1. 啟動服務"
        echo "2. 停止服務"
        echo "3. 重啟服務"
        echo "4. 查看服務狀態"
        echo "5. 查看服務日誌"
        echo "6. 返回主選單"
        echo "==================================="
        
        read -p "請選擇操作 [1-6]: " choice
        
        case $choice in
            1)
                docker-compose up -d
                echo -e "${GREEN}服務已啟動${NC}"
                ;;
            2)
                docker-compose down
                echo -e "${YELLOW}服務已停止${NC}"
                ;;
            3)
                docker-compose restart
                echo -e "${GREEN}服務已重啟${NC}"
                ;;
            4)
                docker-compose ps
                ;;
            5)
                docker-compose logs
                ;;
            6)
                return 0
                ;;
            *)
                echo -e "${RED}無效的選擇！${NC}"
                ;;
        esac
        read -p "按 Enter 鍵繼續..."
    done
}

# Docker 系統管理
manage_docker_system() {
    while true; do
        clear
        echo "==================================="
        echo "    Docker 系統管理"
        echo "==================================="
        echo "1. 檢視所有容器"
        echo "2. 檢視所有映像"
        echo "3. 清理未使用的容器"
        echo "4. 清理未使用的映像"
        echo "5. 清理整個系統"
        echo "6. 啟動 Docker 服務"
        echo "7. 停止 Docker 服務"
        echo "8. 返回主選單"
        echo "==================================="
        
        read -p "請選擇操作 [1-8]: " choice
        
        case $choice in
            1)
                docker ps -a
                ;;
            2)
                docker images
                ;;
            3)
                docker container prune -f
                ;;
            4)
                docker image prune -f
                ;;
            5)
                docker system prune -f
                ;;
            6)
                start_docker
                ;;
            7)
                stop_docker
                ;;
            8)
                return 0
                ;;
            *)
                echo -e "${RED}無效的選擇！${NC}"
                ;;
        esac
        read -p "按 Enter 鍵繼續..."
    done
}

# 設置 Web+SMB 服務
setup_web_smb() {
    local INSTALL_DIR="/opt/docker/web-smb"
    show_status "創建安裝目錄..."
    mkdir -p $INSTALL_DIR

    # [Docker Compose 配置內容與之前相同...]
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
    image: crazymax/samba
    container_name: smb_server
    network_mode: host
    volumes:
      - website_data:/data
      - ./smb.conf:/etc/samba/smb.conf:ro
    environment:
      - TZ=Asia/Taipei
      - USERID=1000
      - GROUPID=1000
    restart: unless-stopped

volumes:
  website_data:
EOF

    # [Nginx 配置內容與之前相同...]
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

    # [SMB 配置內容與之前相同...]
    cat > $INSTALL_DIR/smb.conf << 'EOF'
[global]
    workgroup = WORKGROUP
    server string = Samba Server
    server role = standalone server
    map to guest = Bad User
    dns proxy = no
    socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072
    max protocol = SMB3
    min protocol = SMB2
    security = user
    guest account = nobody
    create mask = 0777
    directory mask = 0777
    load printers = no
    printing = bsd
    printcap name = /dev/null
    disable spoolss = yes

[website]
    comment = Website Files
    path = /data
    browseable = yes
    writable = yes
    guest ok = yes
    public = yes
    force user = root
    force group = root
    create mask = 0777
    directory mask = 0777
EOF

    chmod -R 777 $INSTALL_DIR
    chown -R $SUDO_USER:$SUDO_USER $INSTALL_DIR

    show_status "服務文件已創建在 $INSTALL_DIR"
    
    cd $INSTALL_DIR
    docker-compose up -d

    LOCAL_IP=$(hostname -I | awk '{print $1}')
    echo -e "${GREEN}服務已啟動！${NC}"
    echo -e "網頁訪問：http://$LOCAL_IP"
    echo -e "SMB 網路芳鄰訪問："
    echo -e "  Windows 檔案總管輸入：\\\\$LOCAL_IP\\website"
    echo -e "  或在網路芳鄰中尋找 'Samba Server'"
}

# 主選單
show_menu() {
    clear
    echo "==================================="
    echo "    Docker 安裝和管理助手"
    echo "==================================="
    echo "1. 安裝 Docker"
    echo "2. 安裝 Docker Compose"
    echo "3. 安裝 Web+SMB 服務"
    echo "4. 管理 Web+SMB 服務"
    echo "5. Docker 系統管理"
    echo "6. 安裝所有組件"
    echo "7. 退出"
    echo "==================================="
}

# 主程序
main() {
    check_root
    
    while true; do
        show_menu
        read -p "請選擇操作 [1-7]: " choice
        
        case $choice in
            1)
                if check_docker; then
                    echo -e "${YELLOW}Docker 已安裝！${NC}"
                else
                    install_docker
                fi
                ;;
            2)
                if check_docker_compose; then
                    echo -e "${YELLOW}Docker Compose 已安裝！${NC}"
                else
                    install_docker_compose
                fi
                ;;
            3)
                if ! check_docker || ! check_docker_compose; then
                    echo -e "${RED}請先安裝 Docker 和 Docker Compose！${NC}"
                else
                    setup_web_smb
                fi
                ;;
            4)
                if ! check_docker || ! check_docker_compose; then
                    echo -e "${RED}請先安裝 Docker 和 Docker Compose！${NC}"
                else
                    manage_web_smb
                fi
                ;;
            5)
                if ! check_docker; then
                    echo -e "${RED}請先安裝 Docker！${NC}"
                else
                    manage_docker_system
                fi
                ;;
            6)
                if ! check_docker; then
                    install_docker
                fi
                if ! check_docker_compose; then
                    install_docker_compose
                fi
                setup_web_smb
                ;;
            7)
                echo "感謝使用！"
                exit 0
                ;;
            *)
                echo -e "${RED}無效的選擇！${NC}"
                ;;
        esac
        read -p "按 Enter 鍵繼續..."
    done
}

# 執行主程序
main
