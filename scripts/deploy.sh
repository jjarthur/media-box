#!/bin/bash

script_dir=$(dirname "$(realpath "$0")")

deploy () {
    ssh $host "mkdir -p /docker"
    scp $compose_path $host:/docker

    ssh $host "cd /docker && docker compose up -d --force-recreate"
}

case $1 in
    jellyfin)
        compose_path="$script_dir/../jellyfin/docker-compose.yml"
        host=$JELLYFIN
        ;;
    media)
        compose_path="$script_dir/../media/docker-compose.yml"
        host=$MEDIA
        ;;
    nginx)
        compose_path="$script_dir/../nginx-proxy-manager/docker-compose.yml"
        host=$NGINX
        ;;
    pihole)
        compose_path="$script_dir/../pihole/docker-compose.yml"
        host=$PIHOLE
        ;;
    pdf)
        compose_path="$script_dir/../stirling-pdf/docker-compose.yml"
        host=$PDF
        ;;
    *)
        echo "Invalid argument"
        exit 1;;
esac

deploy
