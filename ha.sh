#!/bin/bash

#ver 1.0.0

# 函數：顯示選單

function show_menu() {

 echo "----------------------------------------"
 echo "HomeAssist 安裝/移除腳本"
 echo "----------------------------------------"
 echo "1. 安裝 HomeAssist"
 echo "2. 移除 HomeAssist"
 echo "0. 退出"
 echo "----------------------------------------"
 echo -n "請輸入您的選擇： "

}

# 函數：安裝 HomeAssist

function install_homeassistant() {

 echo "正在安裝 HomeAssist..."

 # 安裝 Docker

 if ! command -v docker &> /dev/null; then

    echo "正在安裝 Docker..."

    sudo apt update

    sudo apt install docker.io

  fi

 # 建立 HomeAssist 資料夾

 mkdir -p $HOME/homeassistant/config

 mkdir -p $HOME/homeassistant/addone

 # 啟動 HomeAssist

 docker run -d \
    --name homeassistant \
    --privileged \
    --restart=unless-stopped \
    -e TZ=Asia/Taipei \
    -v /homeassistant/config:/config \
    --network=host \
    homeassistant/home-assistant:stable

 echo "HomeAssist 安裝完成。"

}

# 函數：移除 HomeAssist

function remove_homeassistant() {

 echo "正在移除 HomeAssist..."

 # 停止 HomeAssist

 docker stop homeassistant

 # 移除 HomeAssist

 docker rm homeassistant

 # 刪除 HomeAssist 資料夾

 rm -rf $HOME/homeassistant

 echo "HomeAssist 移除完成。"

}

# 主程式

while true; do

 show_menu

 read choice

 case $choice in

  1)
 
    install_homeassistant

    ;;

  2)
 
    remove_homeassistant

    ;;

  0)
 
    echo "結束程式。"

    exit 0

    ;;

  *)
 
    echo "無效的選擇。"

    ;;

  esac

done
