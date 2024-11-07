#!/bin/bash


# ======================
# 可配置區域 - 依需求修改
# ======================
SHARE_PATH="$HOME/share"  # 修改此處可改變共享資料夾位置
BACKUP_DIR="$HOME/.samba_backup"  # 備份目錄

# ======================
# 顏色定義
# ======================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ======================
# 函數定義
# ======================

# 重啟 Samba 服務
restart_samba() {
    echo -e "${GREEN}重啟 Samba 服務...${NC}"
    sudo systemctl restart smbd
    sudo systemctl restart nmbd
    
    # 檢查服務狀態
    if sudo systemctl is-active --quiet smbd; then
        echo -e "${GREEN}Samba 服務已成功重啟${NC}"
    else
        echo -e "${RED}警告：Samba 服務重啟失敗${NC}"
    fi
}

# 備份當前設定
backup_config() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    mkdir -p "$BACKUP_DIR"
    if [ -f /etc/samba/smb.conf ]; then
        sudo cp /etc/samba/smb.conf "$BACKUP_DIR/smb.conf.$timestamp"
        echo -e "${GREEN}設定檔已備份到: $BACKUP_DIR/smb.conf.$timestamp${NC}"
    fi
}

# 編輯設定檔
edit_config() {
    backup_config
    echo -e "${YELLOW}正在打開設定檔進行編輯...${NC}"
    sudo nano /etc/samba/smb.conf
    
    echo -e "${YELLOW}是否要重啟 Samba 服務？(y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        restart_samba
    fi
}

# 完整移除 Samba
remove_samba() {
    echo -e "${RED}警告：這將完全移除 Samba 服務及其設定。${NC}"
    echo -e "${YELLOW}您確定要繼續嗎？此操作無法撤銷！ (yes/no)${NC}"
    read -r confirm
    if [ "$confirm" = "yes" ]; then
        # 備份設定
        backup_config
        
        # 停止服務
        echo -e "${GREEN}停止 Samba 服務...${NC}"
        sudo systemctl stop smbd
        sudo systemctl stop nmbd
        
        # 移除套件
        echo -e "${GREEN}移除 Samba 套件...${NC}"
        sudo apt remove --purge samba samba-common -y
        sudo apt autoremove -y
        
        # 清理設定檔
        echo -e "${GREEN}清理設定檔...${NC}"
        sudo rm -rf /etc/samba
        
        # 移除使用者的 Samba 密碼
        sudo pdbedit -x -u $USER
        
        echo -e "${GREEN}Samba 已完全移除${NC}"
        echo -e "${YELLOW}備份檔案保留在: $BACKUP_DIR${NC}"
    else
        echo -e "${YELLOW}取消移除操作${NC}"
    fi
}

# 顯示當前狀態
show_status() {
    echo -e "\n${GREEN}===== Samba 狀態 =====${NC}"
    
    # 檢查服務狀態
    echo -e "\n${YELLOW}服務狀態：${NC}"
    sudo systemctl status smbd --no-pager | grep "Active:"
    sudo systemctl status nmbd --no-pager | grep "Active:"
    
    # 顯示共享列表
    echo -e "\n${YELLOW}共享列表：${NC}"
    sudo smbstatus -S
    
    # 顯示連接用戶
    echo -e "\n${YELLOW}當前連接：${NC}"
    sudo smbstatus -p
    
    # 顯示網路設定
    echo -e "\n${YELLOW}網路設定：${NC}"
    echo "IP地址: $(hostname -I | cut -d' ' -f1)"
    
    # 顯示防火牆狀態
    if command -v ufw >/dev/null 2>&1; then
        echo -e "\n${YELLOW}防火牆狀態：${NC}"
        sudo ufw status | grep "Samba"
    fi
}

# ======================
# 主選單
# ======================
show_menu() {
    echo -e "\n${GREEN}===== Samba 管理工具 =====${NC}"
    echo "1) 安裝 Samba"
    echo "2) 重啟 Samba 服務"
    echo "3) 修改 Samba 設定"
    echo "4) 顯示當前狀態"
    echo "5) 完全移除 Samba"
    echo "q) 離開"
    echo
    echo -e "${YELLOW}請選擇操作：${NC}"
}

# ======================
# 主程序
# ======================
while true; do
    show_menu
    read -r choice
    case $choice in
        1)
            # 這裡可以執行之前的安裝腳本
            echo -e "${YELLOW}請執行 install-samba.sh 進行安裝${NC}"
            ;;
        2)
            restart_samba
            ;;
        3)
            edit_config
            ;;
        4)
            show_status
            ;;
        5)
            remove_samba
            ;;
        q|Q)
            echo -e "${GREEN}謝謝使用！${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}無效的選擇${NC}"
            ;;
    esac
done
