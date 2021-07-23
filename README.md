# media-box

## jellyfin
### docker-compose.yml
The docker compose file that is used to run Jellyfin. It forwards through the relevant devices needed for hardware acceleration.

### custom-cont-init.d/install.sh
This script grabs the working jellyfin-ffmpeg version needed for VAAPI hardware acceleration.

### LXC config
If you are running docker in an LXC, you will want to mount your data drives, e.g.:

`/etc/pve/lxc/103.conf`
```
mp0: /data-mirror/media/media,mp=/data
mp1: /data-mirror/media/transcodes,mp=/transcodes
```

You will also want to map your host uid/gid to the container uid/gid:

`/etc/pve/lxc/103.conf`
```
lxc.idmap: u 0 100000 1000
lxc.idmap: g 0 100000 1000
lxc.idmap: u 1000 1000 1
lxc.idmap: g 1000 1000 1
lxc.idmap: u 1001 101001 64535
lxc.idmap: g 1001 101001 64535
```

`/etc/subuid`
```
root:1000:1
```
`/etc/subgid`
```
root:1000:1
```

Finally, pass through the render device at `/dev/dri/` with the correct permissions:

`/etc/pve/lxc/103.conf`
```
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

`/etc/pve/lxc/102.conf`
```
mp0: /data-mirror/media,mp=/data
```

You will also want to map your host uid/gid to the container uid/gid:

`/etc/pve/lxc/102.conf`
```
lxc.idmap: u 0 100000 1001
lxc.idmap: g 0 100000 1001
lxc.idmap: u 1001 1001 1
lxc.idmap: g 1001 1001 1
lxc.idmap: u 1002 101002 64534
lxc.idmap: g 1002 101002 64534
```

`/etc/subuid`
```
root:1001:1
```
`/etc/subgid`
```
root:1001:1
```

Finally, pass through the virtual networking device at `/dev/net/` with the correct permissions:

`/etc/pve/lxc/102.conf`
```
lxc.cgroup.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net dev/net none bind,create=dir 0 0
```
