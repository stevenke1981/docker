#!/bin/bash

# 停止所有正在運行的容器
docker stop $(docker ps -aq)

# 刪除所有容器
docker rm $(docker ps -aq)

# 刪除所有映像檔
docker rmi $(docker images -q)

# 刪除所有掛載卷
docker volume rm $(docker volume ls -q)

# 刪除所有網絡
docker network rm $(docker network ls -q)

# 停止Docker守護行程
sudo systemctl stop docker

# 卸載Docker
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 刪除Docker和containerd相關檔案和目錄
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker
sudo rm /etc/apparmor.d/docker
sudo groupdel docker
sudo rm -rf /var/run/docker.sock

echo "Docker已完全卸載!"
