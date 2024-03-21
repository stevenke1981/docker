#!/bin/bash

# 獲取 CPU 型號

cpu_model=$(cat /proc/cpuinfo | grep "model name" | awk '{print $4}')
pool=randomxmonero.auto.nicehash.com:9200
mywallet=38m2mrVGunLYreKxZq4t3hKufuaU97mDHK
workname=x9903

# 根據 CPU 型號選擇

if [[ $cpu_model =~ "AMD" ]]; then
  sudo ./xmrig -a rx/0 -o $pool -u $mywallet.$workname -p x --nicehash --asm=ryzen --donate-level=1
  echo "使用AMD CPU開始計算"
elif [[ $cpu_model =~ "Intel" ]]; then
  sudo ./xmrig -a rx/0 -o $pool -u $mywallet.$workname -p x --nicehash --donate-level=1
  echo "使用Intel CPU開始計算"
else
  echo "無法識別 CPU 型號，請手動指定"
  exit 1
fi

# 暫停
read -p "按 Enter 鍵繼續..."
