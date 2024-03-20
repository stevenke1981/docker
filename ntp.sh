#!/bin/bash

# 安裝 ntpd
sudo apt-get install ntp -y

# 使用 sed 命令添加 NTP 伺服器地址
sudo sed -i '$aserver 0.ubuntu.pool.ntp.org\nserver 1.ubuntu.pool.ntp.org\nserver 2.ubuntu.pool.ntp.org\nserver 3.ubuntu.pool.ntp.org' /etc/ntp.conf

# 啟動 ntpd 服務
sudo service ntp start

# 檢查 ntpd 服務狀態
sudo service ntp status

# 輸出系統時間
date
