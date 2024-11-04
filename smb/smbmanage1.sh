#!/bin/bash

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 定義安裝位置
docker_dir="$HOME/dockerdata/web-smb"

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

# 移除 Docker Compose
remove_docker_compose() {
    show_status "移除 Docker Compose..."
    rm -f /usr/local/bin/docker-compose
    check_status
}

# 移除 Docker
remove_docker() {
    show_status "移除 Docker..."
    apt-get remove --purge -y docker docker-engine docker.io containerd runc
    apt-get autoremove -y
    apt-get autoclean
    rm -rf /var/lib/docker
    check_status
}

# 移除 Web+SMB 服務
remove_web_smb() {
    show_status "移除 Web+SMB 服務..."
    rm -rf "$docker_dir"
    check_status
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
    usermod -aG docker "$SUDO_USER"
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
    local INSTALL_DIR="$docker_dir"
    if [ ! -d "$INSTALL_DIR" ]; then
        echo -e "${RED}Web+SMB 服務尚未安裝！${NC}"
        return 1
    fi
    
    cd "$INSTALL_DIR" || exit
    
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
                read -p "按 Enter 鍵繼續..."
                ;;
            2)
                docker-compose down
                echo -e "${YELLOW}服務已停止${NC}"
                read -p "按 Enter 鍵繼續..."
                ;;
            3)
                docker-compose restart
                echo -e "${GREEN}服務已重啟${NC}"
                read -p "按 Enter 鍵繼續..."
                ;;
            4)
                docker-compose ps
                read -p "按 Enter 鍵繼續..."
                ;;
            5)
                docker-compose logs
                read -p "按 Enter 鍵繼續..."
                ;;
            6)
                return 0
                ;;
            *)
                echo -e "${RED}無效的選擇！${NC}"
                read -p "按 Enter 鍵繼續..."
                ;;
        esac
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
        echo "7. 移除 Web+SMB 服務"
        echo "8. 移除 Docker Compose"
        echo "9. 移除 Docker (完全清理)"
        echo "10. 退出"
        echo "==================================="
        
        read -p "請選擇操作 [1-10]: " choice
        
        case $choice in
            1)
                docker ps -a
                read -p "按 Enter 鍵繼續..."
                ;;
            2)
                docker images
                read -p "按 Enter 鍵繼續..."
                ;;
            3)
                docker container prune -f
                read -p "按 Enter 鍵繼續..."
                ;;
            4)
                docker image prune -f
                read -p "按 Enter 鍵繼續..."
                ;;
            5)
                docker system prune -f
                read -p "按 Enter 鍵繼續..."
                ;;
            6)
                start_docker
                read -p "按 Enter 鍵繼續..."
                ;;
            7)
                if [ -d "$docker_dir" ]; then
                    read -p "確定要移除 Web+SMB 服務嗎？(y/n) " confirm
                    if [ "$confirm" = "y" ]; then
                        remove_web_smb
                        read -p "按 Enter 鍵繼續..."
                    fi
                else
                    echo -e "${YELLOW}Web+SMB 服務未安裝${NC}"
                    read -p "按 Enter 鍵繼續..."
                fi
                ;;
            8)
                if check_docker_compose; then
                    read -p "確定要移除 Docker Compose 嗎？(y/n) " confirm
                    if [ "$confirm" = "y" ]; then
                        remove_docker_compose
                        read -p "按 Enter 鍵繼續..."
                    fi
                else
                    echo -e "${YELLOW}Docker Compose 未安裝${NC}"
                    read -p "按 Enter 鍵繼續..."
                fi
                ;;
            9)
                if check_docker; then
                    read -p "確定要完全移除 Docker 嗎？這將清除所有容器和數據！(y/n) " confirm
                    if [ "$confirm" = "y" ]; then
                        read -p "再次確認，這個操作無法恢復！(y/n) " confirm2
                        if [ "$confirm2" = "y" ]; then
                            remove_docker
                            read -p "按 Enter 鍵繼續..."
                        fi
                    fi
                else
                    echo -e "${YELLOW}Docker 未安裝${NC}"
                    read -p "按 Enter 鍵繼續..."
                fi
                ;;
            10)
                return 0
                ;;
            *)
                echo -e "${RED}無效的選擇！${NC}"
                read -p "按 Enter 鍵繼續..."
                ;;
        esac
    done
}

# 主程序
main_menu() {
    while true; do
        clear
        echo "==================================="
        echo "    Docker & Web+SMB 服務管理"
        echo "==================================="
        echo "1. 安裝 Docker"
        echo "2. 安裝 Docker Compose"
        echo "3. 安裝 Web+SMB 服務"
        echo "4. 管理 Web+SMB 服務"
        echo "5. Docker 系統管理"
        echo "6. 退出"
        echo "==================================="
        
        read -p "請選擇操作 [1-6]: " choice
        
        case $choice in
            1)
                if check_docker; then
                    echo -e "${YELLOW}Docker 已安裝${NC}"
                    read -p "按 Enter 鍵繼續..."
                else
                    install_docker
                    read -p "按 Enter 鍵繼續..."
                fi
                ;;
            2)
                if check_docker_compose; then
                    echo -e "${YELLOW}Docker Compose 已安裝${NC}"
                    read -p "按 Enter 鍵繼續..."
                else
                    install_docker_compose
                    read -p "按 Enter 鍵繼續..."
                fi
                ;;
            3)
                setup_web_smb
                read -p "按 Enter 鍵繼續..."
                ;;
            4)
                manage_web_smb
                ;;
            5)
                manage_docker_system
                ;;
            6)
                echo -e "${GREEN}已退出腳本。${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}無效的選擇！${NC}"
                read -p "按 Enter 鍵繼續..."
                ;;
        esac
    done
}

# 確保腳本以 root 權限執行
check_root

# 啟動主菜單
main_menu
