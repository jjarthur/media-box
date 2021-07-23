apt update
apt-get -y install wget
TEMP_DEB="$(mktemp)" &&
wget -O "$TEMP_DEB" 'https://repo.jellyfin.org/releases/server/ubuntu/versions/jellyfin-ffmpeg/4.3.2-1/jellyfin-ffmpeg_4.3.2-1-focal_amd64.deb' &&
dpkg -i "$TEMP_DEB"
rm -f "$TEMP_DEB"
