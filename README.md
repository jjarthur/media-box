# media-box

## Why?
This media-box is suited for anyone that wants to hardware transcode with an 11th gen `Rocket Lake` processor (e.g. `i5 11500`). This range of processors is not yet natively supported on common distributions (e.g. `Ubuntu 20.04 (Focal Fossa)` and `Debian 10 (Buster)`), and it is also not supported on the `ffmpeg-jellyfin` version that the current version of Jellyfin ships with (`4.3.1-4-focal`). The steps below combined with the steps on [Jellyfin's Hardware Acceleration page](https://jellyfin.org/docs/general/administration/hardware-acceleration.html#configuring-intel-quicksyncqsv-on-debianubuntu) will enable the use of QuickSync. Although I use Jellyfin throughout, there is no reason this shouldn't work with Plex as well.

## What's in the box?
I have the back-end of the media server (Sonarr, Radarr, SABnzbd, etc.) separated from Jellyfin with two different docker-compose files, however there's no reason you can't have everything in the one environment. The reason they are separated is because I run them in two different LXCs within Proxmox. There are instructions for configuring the LXCs if needed.

This isn't a step-by-step instruction guide to set up your media server, but it does cover all the difficult aspects of setting up hardware acceleration for Jellyfin using the `Rocket Lake` processor.

I use NordVPN to route the downloader containers network traffic through, but you can swap this out for your own if necessary.

## jellyfin
***IMPORTANT*: Ubuntu 21.04 must be used for `Rocket Lake` processors.**

### docker-compose.yml
The docker compose file that is used to run Jellyfin. It forwards through the relevant devices needed for hardware acceleration.

### custom-cont-init.d/install.sh
This script grabs the working jellyfin-ffmpeg version needed for VAAPI hardware acceleration. You need to add it to your `/docker/appdata/jellyfin/custom-cont-init.d/install.sh`.

### LXC extra steps

1. [Mount your data drive(s)](#mounting-drives)
2. [Map your ids](#mapping-ids)
3. Finally, pass through the render device at `/dev/dri` with the correct permissions:

**`/etc/pve/lxc/103.conf`**
```bash
lxc.cgroup2.devices.allow: c 226:0 rwm
lxc.cgroup2.devices.allow: c 226:128 rwm
lxc.cgroup2.devices.allow: c 29:0 rwm
lxc.mount.entry: /dev/dri dev/dri none bind,optional,create=dir
lxc.mount.entry: /dev/fb0 dev/fb0 none bind,optional,create=file
```
**Note: You might need to `chmod -R 777 /dev/dri`. If so, this will be required on each restart of your server.**

## media
### docker-compose.yml
The docker compose file that is used to fire up the media box. Includes NordVPN.

**Environment Variables**
* `NORDVPN_USERNAME` - Username for NordVPN
* `NORDVPN_PASSWORD` - Password for NordVPN
* `NORDVPN_CONNECT` -  [country]/[server]/[country_code]/[city]/[group] or [country] [city], e.g. `Australia`.

### LXC extra steps

1. [Mount your data drive(s)](#mounting-drives)
2. [Map your ids](#mapping-ids)
3. Finally, pass through the virtual networking device at `/dev/net/` with the correct permissions:

**`/etc/pve/lxc/102.conf`**
```bash
lxc.cgroup.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net dev/net none bind,create=dir 0 0
```

## LXC configuration

### Mounting drives
If you are running docker in an LXC, you will want to mount your data drives, e.g.:

**`/etc/pve/lxc/103.conf`**
```bash
mp0: /data-mirror/media/media,mp=/data
mp1: /data-mirror/media/transcodes,mp=/transcodes
```

### Mapping ids
You will also want to map your host uid/gid to the container uid/gid:
##### Note: Your own uid/gid mapping may vary, use the below as a guide only. The below is to map uid/gid 1000 in the container to uid/gid 1002 in the host.

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
