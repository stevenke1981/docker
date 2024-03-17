# create working directory structure
mkdir ~/agentdvr/{config,media,commands} -p
# set ownership on the working directories
sudo chown "$USER":"$USER" ~/docker -R
# run the agentdvr container
docker run -d --name=agentdvr -p 8090:8090 -p 3478:3478/udp \
-p 50000-50010:50000-50010/udp \
-v ~/agentdvr/config/:/agent/Media/XML/ \
-v ~/agentdvr/media/:/agent/Media/WebServerRoot/Media/ \
-v ~/agentdvr/commands/:/agent/Commands/ \
-e TZ=Asia/Taipei \
doitandbedone/ispyagentdvr
