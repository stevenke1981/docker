#version 1.0.0

# 定義 Jellyfin 配置和媒體存儲目錄的路徑
jellyfin_config="./jellyfin/config"
jellyfin_media="./jellyfin/media"

# 創建配置和媒體存儲目錄
mkdir -p $jellyfin_config
mkdir -p $jellyfin_media

# 運行 Jellyfin Docker 容器，使用先前定義的參數
docker run -d \
  --name jellyfin \                         # 容器名稱設為 jellyfin
  --privileged \                            # 授予容器額外的權限
  -p 8096:8096 \                            # 映射端口
  --restart=unless-stopped \                # 定義重啟策略
  --volume $jellyfin_config:/config \       # 掛載配置目錄
  --volume /tmp:/cache \                    # 掛載緩存目錄
  --volume $jellyfin_media:/media           # 掛載媒體存儲目錄

# 檢查 Jellyfin 容器是否成功運行
if docker ps | grep -q jellyfin; then
  echo "Jellyfin 容器正在運行。"
  echo "您現在可以通過瀏覽器訪問 http://localhost:8096 來使用 Jellyfin。"
else
  echo "Jellyfin 容器未能成功啟動。請檢查日誌以獲取錯誤信息。"
fi
