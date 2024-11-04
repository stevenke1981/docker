#!/bin/bash

# 定義顏色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 定義安裝目錄
INSTALL_DIR="$HOME/smbserver"

# 顯示狀態消息
show_status() {
    echo -e "${YELLOW}[*] $1${NC}"
}

# 顯示錯誤消息
show_error() {
    echo -e "${RED}[!] 錯誤: $1${NC}"
}

# 顯示成功消息
show_success() {
    echo -e "${GREEN}[✓] $1${NC}"
}

# 創建安裝目錄
setup_directories() {
    show_status "創建必要的目錄..."
    
    mkdir -p "$INSTALL_DIR"/{data,config,logs}
    
    if [ $? -eq 0 ]; then
        show_success "目錄創建成功"
        return 0
    else
        show_error "目錄創建失敗"
        return 1
    fi
}

# 創建 docker-compose 配置
create_docker_compose() {
    show_status "創建 docker-compose.yml..."
    
    cat > "$INSTALL_DIR/docker-compose.yml" << 'EOF'
version: '3'
services:
  samba:
    image: crazymax/samba:latest
    container_name: samba
    environment:
      # 基本設定
      - TZ=Asia/Taipei
      - SAMBA_WORKGROUP=WORKGROUP
      - SAMBA_SERVER_STRING=Samba Server
      - WSDD2_ENABLE=1
      - WSDD2_HOSTNAME=armbian
      # 用戶設定
      - SAMBA_USERS=admin:password;steven:047761816
      # 安全性設定
      - SAMBA_LOG_LEVEL=2
      - SAMBA_SERVER_MIN_PROTOCOL=SMB1
      - SAMBA_SERVER_MAX_PROTOCOL=SMB3
      # 共享設定
      - SHARE1_NAME=share
      - SHARE1_PATH=/mount/data
      - SHARE1_BROWSEABLE=yes
      - SHARE1_READONLY=no
      - SHARE1_GUEST_OK=no
      - SHARE1_VALID_USERS=admin
      - SHARE1_ADMIN_USERS=admin
      - SHARE1_CREATE_MASK=0660
      - SHARE1_DIRECTORY_MASK=0770
    volumes:
      - ./data:/mount/data:rw
      - ./config:/etc/samba:rw
      - ./logs:/var/log/samba:rw
    ports:
      - "139:139/tcp"
      - "445:445/tcp"
    restart: always
EOF

    if [ $? -eq 0 ]; then
        show_success "docker-compose.yml 創建成功"
        return 0
    else
        show_error "docker-compose.yml 創建失敗"
        return 1
    fi
}

# 啟動服務
start_service() {
    show_status "啟動 SMB 服務..."
    
    cd "$INSTALL_DIR" || {
        show_error "無法進入安裝目錄"
        return 1
    }
    
    if sudo docker-compose up -d; then
        show_success "SMB 服務啟動成功"
        echo -e "\n服務資訊："
        echo "SMB 共享: \\\\$(hostname -I | awk '{print $1}')\\share"
        echo "用戶名: admin"
        echo "密碼: password"
        return 0
    else
        show_error "服務啟動失敗"
        return 1
    fi
}

# 停止服務
stop_service() {
    show_status "停止 SMB 服務..."
    
    cd "$INSTALL_DIR" || {
        show_error "無法進入安裝目錄"
        return 1
    }
    
    if sudo docker-compose down; then
        show_success "SMB 服務已停止"
        return 0
    else
        show_error "停止服務失敗"
        return 1
    fi
}

# 主要安裝流程
main() {
    local command=$1
    
    case "$command" in
        "install")
            show_status "開始安裝 SMB 服務..."
            
            setup_directories && \
            create_docker_compose && \
            start_service
            ;;
            
        "stop")
            stop_service
            ;;
            
        "start")
            start_service
            ;;
            
        "restart")
            stop_service && start_service
            ;;
            
        *)
            echo "使用方法: $0 {install|stop|start|restart}"
            exit 1
            ;;
    esac
}

# 執行主函數
main "$@"
