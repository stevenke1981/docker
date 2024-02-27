#!/bin/bash

# Prompt for user input
read -p "Enter MySQL root password: " mysql_root_password
read -p "Enter WordPress database user: " wp_db_user
read -p "Enter WordPress database password: " wp_db_password

# Pull the necessary Docker images
docker pull mariadb
docker pull wordpress:latest

# Create directories for persistent storage
mkdir -p ~/wordpress/database
mkdir -p ~/wordpress/html

# Run the MariaDB container
docker run -e MYSQL_ROOT_PASSWORD="$mysql_root_password" \
          -e MYSQL_USER="$wp_db_user" \
          -e MYSQL_PASSWORD="$wp_db_password" \
          -e MYSQL_DATABASE=wpdb \
          -v ~/wordpress/database:/var/lib/mysql \
          --name wordpressdb  --restart unless-stopped -d mariadb

# Run the WordPress container
docker run -e WORDPRESS_DB_USER="$wp_db_user" \
          -e WORDPRESS_DB_PASSWORD="$wp_db_password" \
          -e WORDPRESS_DB_NAME=wpdb \
          -p 8081:80 \
          -v ~/wordpress/html:/var/www/html \
          --link wordpressdb:mysql \
          --name wpcontainer --restart unless-stopped -d wordpress

echo "MariaDB setup is complete."
echo "WordPress setup is ready. Visit http://localhost:8081 to complete the installation."
