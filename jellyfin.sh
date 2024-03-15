#version 1.0.1
#!/bin/bash

# 定義 Jellyfin 配置和媒體存儲目錄的路徑
jellyfin_config="./jellyfin/config"
jellyfin_media="./jellyfin/media"

# 創建配置和媒體存儲目錄
mkdir -p $jellyfin_config
mkdir -p $jellyfin_media

# 運行 Jellyfin Docker 容器，使用先前定義的參數
docker run -d --name jellyfin --privileged -p 8096:8096 --restart=unless-stopped --volume $jellyfin_config:/config --volume /tmp:/cache --volume $jellyfin_media:/media

# 檢查 Jellyfin 容器是否成功運行
if docker ps | grep -q jellyfin; then
  echo "Jellyfin 容器正在運行。"
  echo "您現在可以通過瀏覽器訪問 http://localhost:8096 來使用 Jellyfin。"
else
  echo "Jellyfin 容器未能成功啟動。請檢查日誌以獲取錯誤信息。"
fi
