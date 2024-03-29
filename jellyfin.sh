#version v1.2.0
#!/bin/bash

if ! dpkg -s exfat-fuse &> /dev/null; then
    echo "exfat-fuse 未安裝，正在安裝..."
    apt install exfat-fuse -y
fi

if ! dpkg -s cifs-utils &> /dev/null; then
    echo "cifs-utils 未安裝，正在安裝..."
    apt install cifs-utils -y
fi


# 定義 Jellyfin 配置和媒體存儲目錄的路徑
jellyfin_config="$HOME/jellyfin/config"
jellyfin_media="$HOME/jellyfin/media"

#Create smb connect
jellyfin_smb="/mnt/smb"
smb_server1_ip="192.168.80.129/data2"
user1=steven
user1pwd=co047787441

mkdir $jellyfin_smb
echo "$jellyfin_smb 建立成功"

mount.cifs //$smb_server1_ip/ $jellyfin_smb -o username=$user1,password=$user1pwd
echo "$jellyfin_smb 掛載成功"


# 啟動 Jellyfin 容器
function start_jellyfin {
  # 創建配置和媒體存儲目錄
  mkdir -p $jellyfin_config
  mkdir -p $jellyfin_media

  # 運行 Jellyfin Docker 容器
  docker run -d --name jellyfin --privileged -p 8096:8096 --restart=unless-stopped \
    --volume $jellyfin_config:/config --volume /tmp:/cache \
    --volume $jellyfin_media:/media \
    --volume $jellyfin_smb:/smb \
    --volume /mnt/sda1:/sda1 \
    nyanmisaka/jellyfin:latest-rockchip

  # 檢查 Jellyfin 容器是否成功運行
  if docker ps | grep -q jellyfin; then
    echo "Jellyfin 容器正在運行。"
    echo "您現在可以通過瀏覽器訪問 http://$(hostname -I | awk '{print $1}'):8096 來使用 Jellyfin。"
  else
    echo "Jellyfin 容器未能成功啟動。請檢查日誌以獲取錯誤信息。"
  fi
}

# 移除 Jellyfin 容器
function remove_jellyfin {
  # 停止 Jellyfin 容器
  docker stop jellyfin

  # 移除 Jellyfin 容器
  docker rm jellyfin

  # 刪除配置和媒體存儲目錄
  rm -rf $jellyfin_config
  rm -rf $jellyfin_media
  rm -rf $HOME/jellyfin

  #移除smb
  umount $jellyfin_smb
  rm -rf $jellyfin_smb
  
  echo "Jellyfin 容器已成功移除。"
}

# 主選單
echo "Jellyfin Docker 管理腳本"
echo "1. 安裝 Jellyfin"
echo "2. 移除 Jellyfin"
echo "3. 離開"
read -p "請選擇操作 (1-3): " action

case $action in
  1)
   
      start_jellyfin
    
    ;;
  2)
    remove_jellyfin
    ;;
  3)
    exit 0
    ;;
  *)
    echo "無效的選擇，退出..."
    exit 1
    ;;
esac
