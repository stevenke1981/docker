#!/bin/bash

echo "此腳本將優化Ubuntu開機速度"
read -p "是否要繼續? (y/n) " confirm

if [[ $confirm == "y" || $confirm == "Y" ]]; then

  echo "正在移除不需要的服務..."
  # 移除不需要的服務
  sudo systemctl disable apt-daily.service
  sudo systemctl disable apt-daily.timer
  sudo systemctl disable apt-daily-upgrade.timer
  sudo systemctl disable fstrim.timer
  sudo systemctl disable motd-news.timer
  sudo systemctl disable NetworkManager-wait-online.service

  echo "正在設置開機選項..."
  # 設置開機選項
  sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash mitigations=off fsck.mode=skip"/g' /etc/default/grub
  sudo update-grub

  echo "正在清理apt緩存..."
  # 清理apt緩存
  sudo apt-get clean
  sudo apt-get autoclean

  echo "正在移除舊內核版本..."
  # 移除舊內核版本
  sudo apt-get purge -y "$(dpkg -l 'linux-image-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\) .*/\1/;/[0-9]/!d' | head -n-1)"

  echo "優化完成!"

else
  echo "已取消優化操作"
fi
