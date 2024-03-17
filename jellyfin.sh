#version 1.0.4
#!/bin/bash

#安裝 exfat-fuse 套件
apt install exfat-fuse -y

#安裝 exfat-utils 套件
apt install exfat-utils -y

# 定義 Jellyfin 配置和媒體存儲目錄的路徑
jellyfin_config="$HOME/jellyfin/config"
jellyfin_media="$HOME/jellyfin/media"


# 檢查外接硬碟是否存在
if lsblk | grep -q /dev/sd0; then
  echo "外接硬碟已連接。"
  jellyfin_tvshows="/dev/sd0/tvshows"
  start_jellyfin0
else
  echo "外接硬碟未連接。"
  start_jellyfin1
fi


function start_jellyfin0 {
  # 創建配置和媒體存儲目錄
  mkdir -p $jellyfin_config
  mkdir -p $jellyfin_media

  # 運行 Jellyfin Docker 容器，使用先前定義的參數
  docker run -d --name jellyfin --privileged -p 8096:8096 --restart=unless-stopped \
  --volume $jellyfin_config:/config --volume /tmp:/cache \
  --volume $jellyfin_media:/media \
  --volume $jellyfin_tvshows:/tvshows \
  nyanmisaka/jellyfin:latest-rockchip

  # 檢查 Jellyfin 容器是否成功運行
  if docker ps | grep -q jellyfin; then
    echo "Jellyfin 容器正在運行。"
    echo "您現在可以通過瀏覽器訪問 http://$(hostname -I | awk '{print $1}'):8096 來使用 Jellyfin。"
  else
    echo "Jellyfin 容器未能成功啟動。請檢查日誌以獲取錯誤信息。"
  fi
}

function start_jellyfin1 {
  # 創建配置和媒體存儲目錄
  mkdir -p $jellyfin_config
  mkdir -p $jellyfin_media

  # 運行 Jellyfin Docker 容器，使用先前定義的參數
  docker run -d --name jellyfin --privileged -p 8096:8096 --restart=unless-stopped \
  --volume $jellyfin_config:/config --volume /tmp:/cache \
  --volume $jellyfin_media:/media \
  nyanmisaka/jellyfin:latest-rockchip

  # 檢查 Jellyfin 容器是否成功運行
  if docker ps | grep -q jellyfin; then
    echo "Jellyfin 容器正在運行。"
    echo "您現在可以通過瀏覽器訪問 http://$(hostname -I | awk '{print $1}'):8096 來使用 Jellyfin。"
  else
    echo "Jellyfin 容器未能成功啟動。請檢查日誌以獲取錯誤信息。"
  fi
}

function remove_jellyfin {
  # 停止 Jellyfin 容器
  docker stop jellyfin

  # 移除 Jellyfin 容器
  docker rm jellyfin

  # 選擇是否刪除配置和媒體存儲目錄
  read -p "是否要刪除配置和媒體存儲目錄？(y/n) " delete_dirs

  if [ "$delete_dirs" = "y" ]; then
    echo "正在刪除配置和媒體存儲目錄..."
    rm -rf $jellyfin_config
    rm -rf $jellyfin_media
    echo "配置和媒體存儲目錄已刪除。"
  else
    echo "保留配置和媒體存儲目錄。"
  fi

  echo "Jellyfin 容器已成功移除。"
}

# 主選單
echo "Jellyfin Docker 管理腳本"
echo "1. 安裝 Jellyfin"
echo "2. 移除 Jellyfin"
read -p "請選擇操作 (1-2): " action

case $action in
  1)
    start_jellyfin
    ;;
  2)
    remove_jellyfin
    ;;
  *)
    echo "無效的選擇，退出..."
    exit 1
    ;;
esac
