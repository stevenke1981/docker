#!/bin/bash

# 停止 Docker 服務
sudo systemctl stop docker
sudo systemctl stop docker.socket

# 備份 Docker 配置
sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak

# 移除 Docker 軟件包
#sudo apt remove docker.io --purge
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras -y

#刪除
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# 刪除 Docker 用戶組
sudo groupdel docker

# 刪除 Docker GPG 密鑰
sudo apt-key del 0EBFCD88

# 輸出提示信息
echo "Docker 已成功移除。"
echo "請重新啟動您的系統以使更改生效。"

# 恢復 Docker 配置
# ... (恢復配置)
