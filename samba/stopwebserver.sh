#!/bin/bash

# 定義顏色代碼
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 定義安裝目錄
INSTALL_DIR="$HOME/dockerdata/web-smb"

# 顯示狀態消息的函數
show_status() {
    echo -e "${YELLOW}[*] $1${NC}"
}

# 顯示錯誤消息的函數
show_error() {
    echo -e "${RED}[!] 錯誤: $1${NC}"
}

# 顯示成功消息的函數
show_success() {
    echo -e "${GREEN}[✓] $1${NC}"
}

# 檢查服務狀態的函數
check_service_status() {
    local container_name=$1
    if docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        return 0 # 運行中
    else
        return 1 # 未運行
    fi
}

# 停止服務的函數
stop_services() {
    show_status "正在停止 Web+SMB 服務..."
    
    # 檢查 docker-compose.yml 是否存在
    if [ ! -f "$INSTALL_DIR/docker-compose.yml" ]; then
        show_error "找不到 docker-compose.yml 文件，服務可能未安裝"
        return 1
    }
    
    # 切換到安裝目錄
    cd "$INSTALL_DIR" || {
        show_error "無法進入安裝目錄 $INSTALL_DIR"
        return 1
    }
    
    # 檢查服務是否正在運行
    if ! check_service_status "web_server" && ! check_service_status "samba"; then
        show_status "服務已經停止"
        return 0
    }
    
    # 嘗試優雅地停止服務
    if sudo docker-compose down --remove-orphans; then
        show_success "服務已成功停止"
        
        # 顯示清理建議
        echo -e "\n${YELLOW}提示：${NC}"
        echo "1. 如果要完全移除服務，可以執行："
        echo "   sudo docker-compose down -v"
        echo "2. 如果要保留數據並在稍後重啟服務，可以執行："
        echo "   sudo docker-compose up -d"
        return 0
    else
        show_error "停止服務時發生錯誤"
        
        # 嘗試強制停止容器
        show_status "嘗試強制停止容器..."
        if sudo docker-compose down --remove-orphans --timeout 30; then
            show_success "服務已被強制停止"
            return 0
        else
            show_error "無法強制停止服務，請手動檢查容器狀態"
            echo "可以使用以下命令檢查容器狀態："
            echo "sudo docker ps"
            return 1
        fi
    fi
}

# 重啟服務的函數
restart_services() {
    show_status "正在重啟 Web+SMB 服務..."
    
    # 先停止服務
    stop_services
    
    # 等待幾秒確保服務完全停止
    sleep 3
    
    # 啟動服務
    if sudo docker-compose up -d; then
        show_success "服務已成功重啟"
        
        # 顯示服務訪問信息
        echo -e "\n服務訪問信息："
        echo "Web 界面: http://$(hostname -I | awk '{print $1}')"
        echo "SMB 共享: \\\\$(hostname -I | awk '{print $1}')\\website"
        return 0
    else
        show_error "重啟服務失敗"
        return 1
    fi
}

# 檢查 Docker 狀態的函數
check_docker_status() {
    if ! command -v docker >/dev/null 2>&1; then
        show_error "Docker 未安裝"
        return 1
    fi
    
    if ! sudo systemctl is-active --quiet docker; then
        show_error "Docker 服務未運行"
        return 1
    fi
    
    return 0
}

# 使用方法的範例：
# 停止服務：
# stop_services

# 重啟服務：
# restart_services

# 使用示例：
# if check_docker_status; then
#     stop_services
# fi
