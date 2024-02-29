#!/bin/bash

#ver 1.0.0

# 創建 openHAB 用戶

sudo useradd -m openhab

# 創建 openHAB 配置、用戶數據和附加組件目錄

sudo mkdir -p /etc/openhab /var/lib/openhab /usr/share/openhab/addons

# 將 openHAB 用戶添加到 docker 組

sudo usermod -aG docker openhab

# 啟動 openHAB

sudo docker run -it --rm --name openhab -p 9080:8080 -v /etc/openhab:/etc/openhab:ro -v /var/lib/openhab:/var/lib/openhab:rw -v /usr/share/openhab/addons:/usr/share/openhab/addons:rw openhab/openhab:latest

