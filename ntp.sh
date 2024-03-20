
好的，以下是自動更新 Linux 系統時間的腳本：

#!/bin/bash

# 安裝 ntpd
sudo apt-get install ntp

# 編輯 ntp.conf 文件
sudo vi /etc/ntp.conf

# 將 # 符號從以下行的開頭刪除：
#server 0.ubuntu.pool.ntp.org
#server 1.ubuntu.pool.ntp.org
#server 2.ubuntu.pool.ntp.org
#server 3.ubuntu.pool.ntp.org

# 啟動 ntpd 服務
sudo service ntp start

# 檢查 ntpd 服務狀態
sudo service ntp status

# 輸出系統時間
date
