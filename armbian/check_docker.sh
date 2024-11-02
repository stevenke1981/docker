#!/bin/bash

# 檢查 Docker 是否已安裝
check_docker() {
  if ! command -v docker &> /dev/null; then
    echo "Docker 未安裝。將開始安裝 Docker..."
    install_docker
  else
    echo "Docker 已安裝。"
  fi
}

# 安裝 Docker
install_docker() {
  echo "開始安裝 Docker..."

  # 更新系統套件並安裝必要套件
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl

  # 設置 Docker 倉庫 GPG 金鑰並添加 Docker 軟件源
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo tee /etc/apt/keyrings/docker.asc >/dev/null
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # 更新軟件包數據庫並安裝 Docker 組件
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # 啟用並啟動 Docker 服務
  sudo systemctl enable --now docker

  # 將當前用戶添加到 Docker 群組
  sudo groupadd docker
  sudo usermod -aG docker $USER

  # 安裝完成提示
  echo "Docker 已成功安裝。請重新啟動系統以應用變更。"
}

# 移除 Docker
remove_docker() {
  echo "開始移除 Docker..."

  # 停止 Docker 服務
  sudo systemctl stop docker docker.socket

  # 移除 Docker 套件
  sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

  # 刪除 Docker 資料和配置
  sudo rm -rf /var/lib/docker /var/lib/containerd /etc/docker
  sudo rm -f /etc/apt/sources.list.d/docker.list
  sudo rm -f /etc/apt/keyrings/docker.asc

  # 刪除 Docker 群組
  sudo groupdel docker

  # 移除完成提示
  echo "Docker 已成功移除。請重新啟動系統以完成移除。"
}

# 主選單
main_menu() {
  echo "請選擇您要執行的操作："
  echo "1) 安裝 Docker"
  echo "2) 移除 Docker"
  echo "3) 退出"
  read -p "請輸入選項 (1/2/3): " choice

  case "$choice" in
    1)
      check_docker
      ;;
    2)
      remove_docker
      ;;
    3)
      echo "已退出。"
      exit 0
      ;;
    *)
      echo "無效選項，請重新選擇。"
      main_menu
      ;;
  esac
}

# 執行主選單
main_menu
