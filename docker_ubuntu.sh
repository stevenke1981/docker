#!/bin/bash

# 卸载旧版本Docker
sudo apt-get remove docker docker-engine docker.io docker-ce containerd.io

# 更新apt包索引
sudo apt-get update

# 安装所需的包
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# 添加Docker官方GPG密钥
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 设置Docker稳定版仓库
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 再次更新apt包索引
sudo apt-get update

# 安装最新版Docker Engine
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 添加当前用户到docker用户组(可选)
sudo usermod -aG docker $USER

# 打印Docker版本
docker --version

echo "Docker安装成功!"
