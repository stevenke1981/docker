#!/bin/bash

set -e

# 檢查 Portainer 資料卷是否存在

if docker volume ls | grep -q "portainer_data"; then

  # 詢問是否刪除 Portainer 資料卷

  echo "Portainer 資料卷已存在。是否刪除？ (y/n)"
  read -r answer

  if [ "$answer" == "y" ]; then

    # 刪除 Portainer 資料卷

    docker volume rm portainer_data

  fi

fi

# 安裝 Docker

curl -fsSL https://get.docker.com/ | sh

# 建立 Portainer 資料卷

docker volume create portainer_data

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
