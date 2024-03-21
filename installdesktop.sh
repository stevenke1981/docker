#!/bin/bash

# Update
sudo apt update && sudo apt upgrade -y

# Install and configure the display manager  
sudo apt install gdm3 -y

# Ubuntu desktop
sudo apt install ubuntu-desktop -y  

# Install xrdp
sudo apt install xrdp xorgxrdp -y

# Configure xrdp to use GNOME (Ubuntu desktop)
# 这一行被注释掉了,因为使用gdm3作为显示管理器,xrdp会自动使用GNOME桌面环境

# Restart xrdp service
sudo systemctl restart xrdp

# Enable xrdp service  
sudo systemctl enable xrdp

# Restart system
sudo reboot
