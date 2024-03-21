#!/bin/bash
sudo apt update
sudo apt install build-essential git dkms bc -y
git clone https://github.com/brektrou/rtl8821CU.git
cd rtl8821CU
chmod +x dkms-install.sh
sudo ./dkms-install.sh

sudo modprobe 8821cu
