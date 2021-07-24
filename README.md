# media-box

## Why?
This media-box is suited for anyone that wants to hardware transcode in Jellyfin with an 11th gen `Rocket Lake` processor. This range of processors is not yet natively supported on common distributions (e.g. `Ubuntu 20.04` and `Debian 10 (Buster)`), and it is also not supported on the `ffmpeg-jellyfin` version that the current version of Jellyfin ships with (`4.3.1-4-focal`).

## What's in the box?
There are instructions for configuring LXC's if needed. I have the back-end of the media server (Sonarr, Radarr, SABnzbd, etc.) separated from Jellyfin with two different LXC containers, however there's no reason you can't have everything in the one environment.

This isn't a step-by-step instruction guide to set up your media server, but it does cover all the difficult aspects of setting up hardware acceleration for Jellyfin using the `Rocket Lake` processor.

I use NordVPN to route the downloader containers network traffic through, but you can swap this out for your own if necessary.

## jellyfin
***IMPORTANT*: Ubuntu 21.04 must be used for `Rocket Lake` processors.**

### docker-compose.yml
The docker compose file that is used to run Jellyfin. It forwards through the relevant devices needed for hardware acceleration.

### custom-cont-init.d/install.sh
This script grabs the working jellyfin-ffmpeg version needed for VAAPI hardware acceleration. You need to add it to your `/docker/appdata/jellyfin/custom-cont-init.d/install.sh`.

### LXC config
If you are running docker in an LXC, you will want to mount your data drives, e.g.:

**`/etc/pve/lxc/103.conf`**
```bash
mp0: /data-mirror/media/media,mp=/data
mp1: /data-mirror/media/transcodes,mp=/transcodes
```

You will also want to map your host uid/gid to the container uid/gid:

**`/etc/pve/lxc/103.conf`**
```bash
lxc.idmap: u 0 100000 1000 # Map uid 0-999 in the container to 100000-100999 in the host
lxc.idmap: g 0 100000 1000 # Map gid 0-999 in the container to 100000-100999 in the host
lxc.idmap: u 1000 1002 1 # Map uid 1000 in the container to 1002 in the host
lxc.idmap: g 1000 1002 1 # Map gid 1000 in the container to 1002 in the host
lxc.idmap: u 1001 101001 64535 # Map uid 1001-65535 in the container to 101001-165535 in the host
lxc.idmap: g 1001 101001 64535 # Map gid 1001-65535 in the container to 101001-165535 in the host
```

**`/etc/subuid`**
```bash
root:1002:1
```

**`/etc/subgid`**
```bash
root:1002:1
```

Finally, pass through the render device at `/dev/dri/` with the correct permissions:

**`/etc/pve/lxc/103.conf`**
```bash
lxc.cgroup2.devices.allow: c 226:0 rwm
lxc.cgroup2.devices.allow: c 226:128 rwm
lxc.cgroup2.devices.allow: c 29:0 rwm
lxc.mount.entry: /dev/dri dev/dri none bind,optional,create=dir
lxc.mount.entry: /dev/fb0 dev/fb0 none bind,optional,create=file
```
**Note: You might need to `chmod -R 666 /dev/dri`**

## media
### docker-compose.yml
The docker compose file that is used to fire up the media box. Includes NordVPN.

**Environment Variables**
* `NORDVPN_USERNAME` - Username for NordVPN
* `NORDVPN_PASSWORD` - Password for NordVPN
* `NORDVPN_CONNECT` -  [country]/[server]/[country_code]/[city]/[group] or [country] [city], e.g. `Australia`.

### LXC config
If you are running docker in an LXC, you will want to mount your data drives, e.g.:

**`/etc/pve/lxc/102.conf`**
```bash
mp0: /data-mirror/media,mp=/data
```

You will also want to map your host uid/gid to the container uid/gid:

**`/etc/pve/lxc/102.conf`**
```bash
lxc.idmap: u 0 100000 1001 # Map uid 0-1000 in the container to 100000-101000 in the host
lxc.idmap: g 0 100000 1001 # Map gid 0-1000 in the container to 100000-101000 in the host
lxc.idmap: u 1001 1001 1 # Map uid 1001 in the container to 1001 in the host
lxc.idmap: g 1001 1001 1 # Map gid 1001 in the container to 1001 in the host
lxc.idmap: u 1002 101002 64534 # Map uid 1002-65535 in the container to 101002-165535 in the host
lxc.idmap: g 1002 101002 64534 # Map gid 1002-65535 in the container to 101002-165535 in the host
```

**`/etc/subuid`**
```bash
root:1001:1
```

**`/etc/subgid`**
```bash
root:1001:1
```

Finally, pass through the virtual networking device at `/dev/net/` with the correct permissions:

**`/etc/pve/lxc/102.conf`**
```bash
lxc.cgroup.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net dev/net none bind,create=dir 0 0
```
