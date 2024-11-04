#version 0.1
#!/bin/bash

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

setup_web_smb() {
    local INSTALL_DIR="/opt/docker/web-smb"
    show_status "創建安裝目錄..."
    mkdir -p $INSTALL_DIR

    # 創建 docker-compose.yml
    cat > $INSTALL_DIR/docker-compose.yml << 'EOF'
version: '3'
services:
  nginx:
    image: nginx:alpine
    container_name: web_server
    ports:
      - "80:80"
    volumes:
      - website_data:/usr/share/nginx/html
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - samba
    restart: unless-stopped

  samba:
    image: crazymax/samba
    container_name: smb_server
    network_mode: host
    volumes:
      - website_data:/data
      - ./smb.conf:/etc/samba/smb.conf:ro
    environment:
      - TZ=Asia/Taipei
      - USERID=1000
      - GROUPID=1000
    restart: unless-stopped

volumes:
  website_data:
EOF

    # 創建 nginx.conf
    cat > $INSTALL_DIR/nginx.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    
    root /usr/share/nginx/html;
    index index.html index.htm;
    
    location / {
        try_files $uri $uri/ =404;
        autoindex on;
    }
}
EOF

    # 創建 smb.conf
    cat > $INSTALL_DIR/smb.conf << 'EOF'
[global]
    workgroup = WORKGROUP
    server string = Samba Server
    server role = standalone server
    map to guest = Bad User
    dns proxy = no
    socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072
    max protocol = SMB3
    min protocol = SMB2
    security = user
    guest account = nobody
    create mask = 0777
    directory mask = 0777
    load printers = no
    printing = bsd
    printcap name = /dev/null
    disable spoolss = yes

[website]
    comment = Website Files
    path = /data
    browseable = yes
    writable = yes
    guest ok = yes
    public = yes
    force user = root
    force group = root
    create mask = 0777
    directory mask = 0777
EOF

    # 設置權限
    chmod -R 777 $INSTALL_DIR
    chown -R $SUDO_USER:$SUDO_USER $INSTALL_DIR

    # 建立一個測試頁面
    mkdir -p $INSTALL_DIR/html
    cat > $INSTALL_DIR/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Welcome</title>
</head>
<body>
    <h1>Web Server is working!</h1>
    <p>This is a test page.</p>
</body>
</html>
EOF

    show_status "服務文件已創建在 $INSTALL_DIR"
    
    # 自動啟動服務
    cd $INSTALL_DIR
    docker-compose down
    docker-compose up -d

    # 顯示訪問信息
    LOCAL_IP=$(hostname -I | awk '{print $1}')
    echo -e "${GREEN}服務已啟動！${NC}"
    echo -e "網頁訪問：http://$LOCAL_IP"
    echo -e "SMB 網路芳鄰訪問："
    echo -e "  Windows 檔案總管輸入：\\\\$LOCAL_IP\\website"
    echo -e "  或在網路芳鄰中尋找 'Samba Server'"
}

# ... [其餘的腳本內容保持不變] ...
