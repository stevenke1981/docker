#!/bin/bash

# Update
sudo apt update && sudo apt upgrade -y

# Install and configure the display manager, another lightdm, gdm3,kdm
sudo apt install slim -y

# Ubuntu desktop
sudo apt install ubuntu-desktop -y
#sudo apt installl xfce -y

# Restart
sudo reboot

#XFCE包
#sudo apt-get install xfce4-session xfce4-goodies
