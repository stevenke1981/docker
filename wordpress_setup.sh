#!/bin/bash

# 函式：移除 WordPress 和 MariaDB
function remove_wordpress() {
  echo "移除 WordPress 和 MariaDB..."

  # 停止並移除容器
  docker stop wordpressdb wpcontainer
  docker rm wordpressdb wpcontainer

  # 移除持久化資料
  rm -rf ~/wordpress/database ~/wordpress/html

  echo "WordPress 和 MariaDB 已移除。"
}

# 顯示選單
echo "** WordPress 安裝和移除工具 **"
echo "1. 安裝 WordPress 和 MariaDB"
echo "2. 移除 WordPress 和 MariaDB (一鍵)"
echo "3. 離開"
read -p "輸入您的選擇： " choice

# 處理使用者輸入
case "$choice" in
  1)
    # 提示使用者輸入
    read -p "輸入 MySQL root 密碼： " mysql_root_password
    read -p "輸入 WordPress 資料庫使用者： " wp_db_user
    read -p "輸入 WordPress 資料庫密碼： " wp_db_password

    # 建立資料夾
    mkdir -p ~/wordpress/database ~/wordpress/html

    # 建立 MariaDB 容器
    docker run -e MYSQL_ROOT_PASSWORD="$mysql_root_password" \
      -e MYSQL_USER="$wp_db_user" \
      -e MYSQL_PASSWORD="$wp_db_password" \
      -e MYSQL_DATABASE=wpdb \
      -v ~/wordpress/database:/var/lib/mysql \
      --name wordpressdb --restart unless-stopped -d mariadb

    # 建立 WordPress 容器
    docker run -e WORDPRESS_DB_USER="$wp_db_user" \
      -e WORDPRESS_DB_PASSWORD="$wp_db_password" \
      -e WORDPRESS_DB_NAME=wpdb \
      -p 8081:80 \
      -v ~/wordpress/html:/var/www/html \
      --link wordpressdb:mysql \
      --name wpcontainer --restart unless-stopped -d wordpress

    echo "MariaDB 安裝完成。"
    echo "WordPress 安裝完成。請訪問 http://$(hostname -I | awk '{print $1}'):8081 完成安裝。"
    ;;
  2)
    remove_wordpress
    ;;
  3)
    echo "離開..."
    exit 0
    ;;
  *)
    echo "無效的選擇。"
    ;;
esac
