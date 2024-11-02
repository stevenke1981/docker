#!/bin/bash

set -e

# 檢查安裝 Docker

function check_docker_install() {
  if ! command -v docker &> /dev/null; then
    echo "Docker 未安裝。請先安裝 Docker。"
    exit 1
  fi
}

# 主程式

# 檢查 Docker 安裝

check_docker_install

# 建立 Portainer 資料卷

docker volume create portainer_data
echo "Portainer 資料卷建立成功!"

# 執行 Portainer 容器

docker run -d \
  -p 9000:9000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

# 顯示 Portainer 網址

echo "Portainer 網址：http://$(hostname -I | awk '{print $1}'):9000"
echo "Portainer 網址：http://$(hostname -I | awk '{print $1}'):9443"
