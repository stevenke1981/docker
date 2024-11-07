#!/bin/bash

# ======================
# 可配置區域 - 依需求修改
# ======================
SHARE_PATH="$HOME/share"  # 修改此處可改變共享資料夾位置

# ======================
# 腳本開始
# ======================

# 顏色定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 獲取真實用戶名稱
REAL_USER=$USER
SHARE_PATH=$(eval echo "$SHARE_PATH")

# 密碼設置函數
set_samba_password() {
    local password_set=0
    while [ $password_set -eq 0 ]; do
        echo -e "${YELLOW}請設置 Samba 密碼：${NC}"
        read -s password
        echo
        echo -e "${YELLOW}請再次輸入密碼確認：${NC}"
        read -s password_confirm
        echo
        
        if [ "$password" = "$password_confirm" ]; then
            if [ -z "$password" ]; then
                echo -e "${RED}錯誤：密碼不能為空${NC}"
                continue
            fi
            
            # 直接使用 echo 傳遞密碼到 smbpasswd
            echo -e "$password\n$password" | sudo smbpasswd -s -a $REAL_USER
            
            # 檢查密碼是否設置成功
            if sudo pdbedit -L | grep -q "^$REAL_USER:"; then
                echo -e "${GREEN}Samba 密碼設置成功！${NC}"
                password_set=1
            else
                echo -e "${RED}密碼設置失敗，請重試${NC}"
            fi
        else
            echo -e "${RED}錯誤：兩次輸入的密碼不匹配，請重試${NC}"
        fi
    done
}

# 顯示設定資訊
echo -e "${YELLOW}將使用以下設定：${NC}"
echo -e "用戶名稱: ${GREEN}$REAL_USER${NC}"
echo -e "共享路徑: ${GREEN}$SHARE_PATH${NC}"
echo -e "${YELLOW}按 Enter 繼續，或 Ctrl+C 取消${NC}"
read

echo -e "${GREEN}開始安裝 Samba...${NC}"

# 檢查並安裝必要套件
echo -e "${GREEN}檢查並安裝必要套件...${NC}"
sudo apt update
sudo apt install -y samba samba-common-bin

# 創建共享資料夾
echo -e "${GREEN}創建共享資料夾...${NC}"
mkdir -p "$SHARE_PATH"
sudo chown $REAL_USER:$REAL_USER "$SHARE_PATH"
chmod 755 "$SHARE_PATH"

# 備份原始配置
echo -e "${GREEN}備份原始 Samba 配置...${NC}"
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# 創建新的 Samba 配置
echo -e "${GREEN}配置 Samba...${NC}"
sudo tee /etc/samba/smb.conf > /dev/null << EOF
[global]
workgroup = WORKGROUP
server string = Samba Server %h
security = user
map to guest = bad user
dns proxy = no
log level = 1
max log size = 1000
logging = file
panic action = /usr/share/samba/panic-action %d

# 增加效能的設定
socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=65536 SO_SNDBUF=65536
read raw = yes
write raw = yes
oplocks = yes
max xmit = 65535
dead time = 15
getwd cache = yes

# 共享資料夾設定
[share]
path = $SHARE_PATH
comment = Home Share Directory
browseable = yes
read only = no
valid users = $REAL_USER
create mask = 0644
directory mask = 0755
EOF

# 設置 Samba 密碼
echo -e "${YELLOW}設置 Samba 密碼${NC}"
set_samba_password

# 重啟 Samba 服務
echo -e "${GREEN}重啟 Samba 服務...${NC}"
sudo systemctl restart smbd
sudo systemctl restart nmbd

# 配置防火牆
echo -e "${GREEN}配置防火牆...${NC}"
if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow samba
fi

# 獲取IP地址
IP_ADDRESS=$(hostname -I | cut -d' ' -f1)

# 完成安裝
echo -e "\n${GREEN}====== Samba 安裝完成！======${NC}"
echo -e "${YELLOW}連接資訊：${NC}"
echo -e "網路路徑: \\\\${IP_ADDRESS}\\share"
echo -e "用戶名: ${REAL_USER}"
echo -e "共享資料夾位置: ${SHARE_PATH}"
echo -e "\n${YELLOW}Windows 連接方式：${NC}"
echo -e "1. 打開檔案總管"
echo -e "2. 輸入網路路徑: \\\\${IP_ADDRESS}\\share"
echo -e "3. 使用以下帳密登入："
echo -e "   用戶名: ${REAL_USER}"
echo -e "   密碼: 您剛才設置的 Samba 密碼"

# 測試 Samba 連接
echo -e "\n${GREEN}測試 Samba 設定：${NC}"
if sudo pdbedit -L | grep -q "^$REAL_USER:"; then
    echo -e "${GREEN}用戶設定正確${NC}"
else
    echo -e "${RED}警告：用戶設定可能有問題${NC}"
fi

# 檢查服務狀態
echo -e "\n${GREEN}服務狀態檢查：${NC}"
if sudo systemctl is-active --quiet smbd; then
    echo -e "${GREEN}Samba 服務運行中${NC}"
else
    echo -e "${RED}警告：Samba 服務未運行${NC}"
fi

# 顯示防火牆狀態
if command -v ufw >/dev/null 2>&1; then
    echo -e "\n${GREEN}防火牆狀態：${NC}"
    sudo ufw status | grep "Samba"
fi

echo -e "\n${GREEN}====== 安裝程序執行完畢 ======${NC}"
