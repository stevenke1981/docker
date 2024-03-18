docker run -d \
--name jellyfinny \
--privileged \
-p 8096:8096 \
--restart=unless-stopped \
--volume $HOME/jellyfin/config:/config \
--volume $HOME/jellyfin/cache:/cache \
--volume $HOME/jellyfin/media:/media \
`for dev in dri dma_heap mali0 rga mpp_service \
    iep mpp-service vpu_service vpu-service \
    hevc_service hevc-service rkvdec rkvenc vepu h265e ; do \
   [ -e "/dev/$dev" ] && echo " --device /dev/$dev"; \
  done` \
nyanmisaka/jellyfin:latest-rockchip

#jjm2473/jellyfin-mpp:latest
