#version v1.2.0
#!/bin/bash

# 安裝 exfat-fuse 套件
apt install exfat-fuse -y

# 定義 Jellyfin 配置和媒體存儲目錄的路徑
jellyfin_config="$HOME/jellyfin/config"
jellyfin_media="$HOME/jellyfin/media"

# 檢查硬碟是否存在
if [ ! -b /dev/sda ] || [ ! -b /dev/sdb ] || [ ! -b /dev/sdc ] || [ ! -b /dev/sdd ]; then
  echo "找不到外接硬碟。"
  exit 1
fi

# 檢查硬碟是否已格式化
if [ ! -f /dev/sda1 ] || [ ! -f /dev/sdb1 ] || [ ! -f /dev/sdc1 ] || [ ! -f /dev/sdd1 ]; then
  echo "外接硬碟未格式化。"
  exit 1
fi

# 檢查外接硬碟是否已連接
count=0
for disk in $disks; do
  if [ "$disk" = "sda" ] || [ "$disk" = "sdb" ] || [ "$disk" = "sdc" ] || [ "$disk" = "sdd" ]; then
    echo "外接硬碟 /dev/$disk 已連接。"
    jellyfin_sd"i"="/dev/<span class="math-inline">disk/"
count\=</span>((count + 1))
  else
    echo "外接硬碟 /dev/$disk 未連接。"
  fi
done

# 啟動 Jellyfin 容器
function start_jellyfin {
  # 創建配置和媒體存儲目錄
  mkdir -p $jellyfin_config
  mkdir -p $jellyfin_media

  # 運行 Jellyfin Docker 容器
  docker run -d --name jellyfin --privileged -p 8096:8096 --restart=unless-stopped \
    --volume $jellyfin_config:/config --volume /tmp:/cache \
    --volume $jellyfin_media:/media \
    "${jellyfin_sd[@]}" \
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
