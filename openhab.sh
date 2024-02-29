#!/bin/bash

#ver 1.0.0

# 函數：顯示選單

function show_menu() {

  echo "----------------------------------------"
  echo "openHAB 安裝/移除腳本"
  echo "----------------------------------------"
  echo "1. 安裝 openHAB"
  echo "2. 移除 openHAB"
  echo "0. 退出"
  echo "----------------------------------------"
  echo -n "請輸入您的選擇： "

}

# 主程式

while true; do

  show_menu

  read choice

  case "$choice" in

    1)

      echo "正在安裝 openHAB..."

      # 安裝 openHAB
      # 必須先安裝好docker

      # 創建 openHAB 用戶

      sudo useradd -m openhab

      # 創建 openHAB 配置、用戶數據和附加組件目錄

      sudo mkdir -p /etc/openhab /var/lib/openhab /usr/share/openhab/addons

      # Create the openhab user

      sudo useradd -r -s /sbin/nologin openhab
      sudo usermod -a -G openhab openhab

      #Create the openHAB conf, userdata, and addon directories

      sudo mkdir -p /opt/openhab/{conf,userdata,addons}
      sudo chown -R openhab:openhab /opt/openhab
      

      # 啟動 openHAB

      #sudo docker run -it --rm --name openhab -p 9080:8080 -v /etc/openhab:/etc/openhab:ro -v /var/lib/openhab:/var/lib/openhab:rw -v /usr/share/openhab/addons:/usr/share/openhab/addons:rw openhab/openhab:latest

      docker run \
        --name openhab \
        --net=host \
        -v /etc/localtime:/etc/localtime:ro \
        -v /etc/timezone:/etc/timezone:ro \
        -v /opt/openhab/conf:/openhab/conf \
        -v /opt/openhab/userdata:/openhab/userdata \
        -v /opt/openhab/addons:/openhab/addons \
        -d \
        --restart=always \
        openhab/openhab:latest
      
      
      echo "openHAB 已安裝完成。"

      break

      ;;

    2)

      echo "正在移除 openHAB..."

      # 停止 openHAB 容器

      sudo docker stop openhab

      # 刪除 openHAB 容器

      sudo docker rm openhab

      # 刪除 openHAB 用戶

      sudo userdel openhab

      # 刪除 openHAB 配置、用戶數據和附加組件目錄

      sudo rm -rf /etc/openhab /var/lib/openhab /usr/share/openhab/addons

      echo "openHAB 已移除完成。"

      break

      ;;

    0)

      echo "退出腳本。"

      exit 0

      ;;

    *)

      echo "無效的選擇，請重新輸入。"

      ;;

  esac

done
