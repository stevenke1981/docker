#!/bin/bash

# 更新軟件庫
sudo apt update

# 安裝Xfce桌面環境
sudo apt install xfce4 xfce4-goodies -y

# 安裝顯示管理器LightDM
sudo apt install lightdm -y

# 設置LightDM為默認顯示管理器
sudo dpkg-reconfigure lightdm

# 安裝VNC服務器(如果需要遠程訪問桌面)
#sudo apt install tightvncserver -y  

# 設置VNC服務器密碼(如果安裝了VNC)
#echo "設置VNC服務器密碼:"
#vncserver

# 設置Xfce為默認桌面環境
sudo echo "xfce4-session" > /home/$USER/.xsession

# 重啓系統,應用更改
echo "是否立即重啓系統?(y/n)"
read restart

if [ "$restart" = "y" ]; then
  sudo reboot
fi
