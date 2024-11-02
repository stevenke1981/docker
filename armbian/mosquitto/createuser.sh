#開機啟動mosquitto
sudo systemctl enable mosquitto
sudo systemctl start mosquitto



#假如我們要建立一個帳號 叫做qquser的話，可以用下面這指令

# 建立 myuser 帳號與密碼，儲存於 /etc/mosquitto/passwd
sudo mosquitto_passwd -c /etc/mosquitto/passwd qquser


#要輸入兩次這個帳號要給的密碼，輸入完成就可以了。
#如果幫帳號改密碼也是同樣操作，
#而這裡建立好的帳號我們將其儲存於 /etc/mosquitto/passwd 


#編輯 Mosquitto 設定檔 /etc/mosquitto/conf.d/default.conf
#在這個設定檔案中指定 Mosquitto 帳號與密碼設定檔的位置，
#這個檔案預設是不存在的，建立這個檔案之後，寫入以下設定：

# 禁止匿名連線
allow_anonymous false

# 指定帳號與密碼設定檔位置
password_file /etc/mosquitto/passwd

#設定好後要記得重新啟動服務

# 重新啟動 mosquitto 服務
sudo systemctl restart mosquitto
