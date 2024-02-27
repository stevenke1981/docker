#!/bin/bash

# 更新系統
sudo apt update

# 安裝 Docker GPG 密鑰
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

# 添加 Docker 軟件倉庫
sudo add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

# 安裝 Docker
sudo apt install docker.io

# 啟動 Docker 服務
sudo systemctl start docker

# 啟用 Docker 服務
sudo systemctl enable docker

# 創建 Docker 用戶組
sudo groupadd docker

# 將當前用戶添加到 Docker 用戶組
sudo usermod -aG docker $USER

# 輸出提示信息
echo "Docker 已成功安裝。"
echo "請重新啟動您的系統以使更改生效。"
