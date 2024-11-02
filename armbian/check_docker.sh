#!/bin/bash

check_docker() {
  if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    sudo apt update && sudo apt install -y docker.io
    echo "Docker installed successfully."
  else
    echo "Docker is already installed."
  fi
}


install_docker() {

# 更新系統
#sudo apt update

# 安裝 Docker GPG 密鑰
#curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

# 添加 Docker 軟件倉庫
#sudo add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update


# 安裝 Docker
#sudo apt install docker.io
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

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

}


remove_docker() {

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

}

