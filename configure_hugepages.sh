#!/bin/bash

# 检查是否以root权限运行
if [ "$(id -u)" -ne 0 ]; then
  echo "请以root权限运行此脚本"
  exit 1
fi

# 提示用户输入所需的 Huge Pages 数量
read -p "请输入所需的 Huge Pages 数量: " huge_pages

# 编辑 /etc/sysctl.conf 文件
echo "vm.nr_hugepages=$huge_pages" | sudo tee -a /etc/sysctl.conf

# 重新加载 sysctl 配置
sudo sysctl -p

echo "Huge Pages 已配置完成"
