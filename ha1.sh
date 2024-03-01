#!/bin/bash

# Version 1.0.1

# Global configuration
HASS_CONFIG_DIR="$HOME/homeassistant/config"
HASS_DOCKER_IMAGE="homeassistant/home-assistant:stable"
HACS_VERSION="1.34.0"
HACS_DOWNLOAD_URL="https://github.com/hacs/integration/releases/download/${HACS_VERSION}/hacs.zip"
HACS_INSTALL_DIR="$HASS_CONFIG_DIR/custom_components/hacs"

# Function: Show the menu
show_menu() {
  echo "----------------------------------------"
  echo "HomeAssist Installation/Removal Script"
  echo "----------------------------------------"
  echo "1. Install HomeAssist"
  echo "2. Remove HomeAssist"
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
install_homeassistant() {
  echo "Installing HomeAssist..."

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
    -p 8123:8123/tcp -e TZ=Asia/Taipei -v "$HASS_CONFIG_DIR:/config" homeassistant/home-assistant:stable && echo "HomeAssist installed successfully." || { echo "Failed to start Home Assistant."; exit 1; }

  echo "HomeAssist accessible at: http://$(hostname -I | awk '{print $1}'):8123"
}

# Function: Remove HomeAssistant
remove_homeassistant() {
  echo "Removing HomeAssist..."

  docker stop homeassistant && docker rm homeassistant && echo "Home Assistant container removed." || { echo "Failed to remove Home Assistant container."; }

  rm -rf "$HASS_CONFIG_DIR" && echo "HomeAssist removed successfully." || { echo "Failed to remove HomeAssist configuration."; }
}

# Main program loop
while true; do
  show_menu
  read -r choice

  case $choice in
    1)
      install_homeassistant
      ;;
    2)
      remove_homeassistant
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
