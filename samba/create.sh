#!/bin/bash

# 創建 Samba 配置目錄
dockerdata_dir="$HOME/dockerdata/samba"

mkdir -p "$dockerdata_dir/config"
mkdir -p "$dockerdata_dir/data"

# 創建 docker-compose.yml 文件
cat > "$dockerdata_dir/docker-compose.yml" <<EOF
version: '3.8'

services:
  samba:
    image: crazymax/samba:latest
    container_name: samba
    environment:
      - TZ=Asia/Taipei  # 設置您的時區
      - SAMBA_WORKGROUP=WORKGROUP  # 默認工作組名稱
      - SAMBA_SERVER_STRING=Armbian Samba Server  # 服務器描述字段
      - SAMBA_LOG_LEVEL=2
      - SAMBA_FOLLOW_SYMLINKS=yes
      - SAMBA_WIDE_LINKS=yes
      - SAMBA_HOSTS_ALLOW=192.168.80.0/24
      - WSDD2_ENABLE=1  # 啟用 Windows 服務發現
      - WSDD2_NETBIOS_NAME=MySambaServer  # 設置 NetBIOS 名稱
    volumes:
      - ./data:/mount/data  # 共享文件的本地路徑
      - ./config:/etc/samba  # 用於存儲smb配置
    ports:
      - "137:137/udp"
      - "138:138/udp"
      - "139:139/tcp"
      - "445:445/tcp"
    restart: always
EOF

# 創建 smb.conf 文件
cat > "$dockerdata_dir/config/smb.conf" <<EOF
[global]
  workgroup = WORKGROUP
  security = user
  map to guest = bad user
  log file = /var/log/samba/log.%m
  max log size = 50

[shared]
  path = /mount/data  # 與 docker-compose 中的路徑對應
  browseable = yes
  writable = yes
  guest ok = yes
  read only = no
EOF

# 創建啟動腳本
cat > "$dockerdata_dirstart-samba.sh" <<EOF
#!/bin/bash
cd "$dockerdata_dir/samba"
docker-compose up -d
EOF

# 設置啟動腳本的執行權限
chmod +x /home/armbian/start-samba.sh

# 提示完成
echo "Samba Docker 配置完成！運行 "$dockerdata_dir/start-samba.sh" 來啟動 Samba 服務。"
