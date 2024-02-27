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

# 停止 Portainer 容器

docker stop portainer

# 刪除 Portainer 容器

docker rm portainer

# 刪除 Portainer 資料卷

docker volume rm portainer_data

echo "Portainer 已成功移除。"
