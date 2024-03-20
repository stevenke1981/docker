#!/bin/bash

# 切換到目前目錄
cd "$(dirname "$0")"

# 執行 x
./xmrig -a rx/0 -o randomxmonero.auto.nicehash.com:9200 -u 38m2mrVGunLYreKxZq4t3hKufuaU97mDHK.x9903 -p x --nicehash --asm=ryzen --donate-level=1 --intensity 90

# 暫停
read -p "按 Enter 鍵繼續..."
