#!/bin/bash

set -e

# 檢查安裝 Docker

function check_docker_install() {
  if ! command -v docker &> /dev/null; then
    echo "Docker 未安裝。請先安裝 Docker。"
    exit 1
  fi
}

# 檢查安裝 Portainer 資料卷

function check_portainer_data_volume() {
  if docker volume ls | grep -q "portainer_data"; then
    echo "Portainer 資料卷已存在。"
    return 0
  else
    echo "Portainer 資料卷不存在。"
    return 1
  fi
}

# 主程式

check_docker_install

if check_portainer_data_volume; then

  # 詢問是否刪除 Portainer 資料卷

  echo "是否刪除 Portainer 資料卷？ (y/n)"
  read -r answer

  if [ "$answer" == "y" ]; then

    # 先停止使用 Portainer 資料卷的容器

    docker ps -a | grep portainer_data | awk '{print $1}' | xargs docker stop

    # 刪除 Portainer 資料卷

    docker volume rm portainer_data

  else

    # 跳出安裝程式

    exit 0

  fi

fi

# 安裝 Docker

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
