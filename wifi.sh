sudo apt install wireless-tools net-tools -y

iwconfig wlan0 mode managed

iwlist wlan0 scan
