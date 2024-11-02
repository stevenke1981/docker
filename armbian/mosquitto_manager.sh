#!/bin/bash

# 檢查是否以 root 權限運行腳本
if [ "$EUID" -ne 0 ]; then
  echo "請以 root 權限運行此腳本"
  exit
fi

# 功能選單
function show_menu() {
  echo "====================="
  echo "  Mosquitto 控制選單"
  echo "====================="
  echo "1) 安裝 Mosquitto"
  echo "2) 移除 Mosquitto"
  echo "3) 退出"
  echo -n "請選擇一個選項: "
}

# 安裝 Mosquitto 函數
function install_mosquitto() {
  echo "正在更新系統並安裝 Mosquitto..."
  sudo apt update
  sudo apt install -y mosquitto mosquitto-clients
  sudo systemctl enable mosquitto
  sudo systemctl start mosquitto
  echo "Mosquitto 已安裝並啟動。"
}

# 移除 Mosquitto 函數
function remove_mosquitto() {
  echo "正在移除 Mosquitto..."
  sudo systemctl stop mosquitto
  sudo apt remove --purge -y mosquitto mosquitto-clients
  sudo apt autoremove -y
  echo "Mosquitto 已移除。"
}

# 主程式循環
while true; do
  show_menu
  read choice
  case $choice in
    1)
      install_mosquitto
      ;;
    2)
      remove_mosquitto
      ;;
    3)
      echo "退出選單。"
      exit 0
      ;;
    *)
      echo "無效選項，請重新選擇。"
      ;;
  esac
done
