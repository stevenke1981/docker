#!/bin/bash

check_docker() {
  if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    sudo apt update && sudo apt install -y docker.io
    echo "Docker installed successfully."
  else
    echo "Docker is already installed."
  fi
}
