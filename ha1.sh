#!/bin/bash

# Version 1.0.1

# Global configuration
HASS_CONFIG_DIR="$HOME/homeassistant/config"
HASS_DOCKER_IMAGE="homeassistant/home-assistant:stable"
HACS_VERSION="1.34.0"
HACS_DOWNLOAD_URL="https://github.com/hacs/integration/releases/download/${HACS_VERSION}/hacs.zip"
HACS_INSTALL_DIR="$HASS_CONFIG_DIR/custom_components/hacs"
TIME_ZONE="Asia/Taipei"  

# Function: Show the menu
show_menu() {
  echo "----------------------------------------"
  echo "HomeAssistant Installation/Removal Script"
  echo "----------------------------------------"
  echo "1. Install HomeAssistant"
  echo "2. Remove HomeAssistant"
  echo "0. Exit"
  echo "----------------------------------------"
  echo -n "Enter your choice: "
}

# Function: Check Docker installation
check_docker() {
  if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    sudo apt update && sudo apt install -y docker.io
    echo "Docker installed successfully."
  else
    echo "Docker is already installed."
  fi
}

# Function: Install HomeAssistant
install_HomeAssistant() {
  echo "Installing HomeAssistant..."

  check_docker

  # Create HomeAssistant directories
  mkdir -p "$HACS_INSTALL_DIR"

  # Download and install HACS
  echo "Downloading HACS..."
  wget -q "$HACS_DOWNLOAD_URL" -O "$HACS_INSTALL_DIR/hacs.zip" && echo "HACS downloaded successfully." || { echo "Failed to download HACS."; exit 1; }

  echo "Extracting HACS..."
  unzip -q "$HACS_INSTALL_DIR/hacs.zip" -d "$HACS_INSTALL_DIR" && echo "HACS extracted successfully." || { echo "Failed to extract HACS."; exit 1; }

  # Clean up
  rm "$HACS_INSTALL_DIR/hacs.zip"

  # Start HomeAssistant container
  echo "Starting Home Assistant..."
  docker run -d --name homeassistant --restart unless-stopped \
    -p 8123:8123/tcp --network host -e TZ="$TIME_ZONE" -v "$HASS_CONFIG_DIR:/config" \
    -v /run/dbus:/run/dbus:ro homeassistant/home-assistant:stable && echo "HomeAssistant installed successfully." || { echo "Failed to start Home Assistant."; exit 1; }

  echo "HomeAssistant accessible at: http://$(hostname -I | awk '{print $1}'):8123"
}

# Function: Remove HomeAssistant
remove_HomeAssistant() {
  echo "Removing HomeAssistant..."

  docker stop homeassistant && docker rm homeassistant && echo "Home Assistant container removed." || { echo "Failed to remove Home Assistant container."; }

  rm -rf "$HASS_CONFIG_DIR" && echo "HomeAssistant removed successfully." || { echo "Failed to remove HomeAssistant configuration."; }
}

# Main program loop
while true; do
  show_menu
  read -r choice

  case $choice in
    1)
      install_HomeAssistant
      ;;
    2)
      remove_HomeAssistant
      ;;
    0)
      echo "Exiting."
      exit 0
      ;;
    *)
      echo "Invalid choice."
      ;;
  esac
done
