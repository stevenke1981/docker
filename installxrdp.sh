#!/bin/bash

# 安裝xrdp遠端桌面服務
sudo apt install xrdp xorgxrdp -y

# 設置xrdp使用當前桌面環境(假設為Xfce)
echo "xfce4-session" > ~/.xsession
sudo sed -i 's/\(fi\)/startxfce4\n\1/' /etc/xrdp/startxrdp.sh

# 重啟xrdp服務
sudo systemctl restart xrdp

# 設定xrdp在系統啟動時自動啟用
sudo systemctl enable xrdp

echo "XRDP已設置完成,可以使用Windows遠端桌面連接到此伺服器"
