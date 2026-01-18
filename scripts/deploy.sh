#!/bin/bash

script_dir=$(dirname "$(realpath "$0")")
services_dir="$script_dir/../services"

deploy () {
    ssh $host "mkdir -p /docker"
    scp $compose_path $host:/docker

    ssh $host "cd /docker && docker compose up -d --force-recreate"
}

case $1 in
    jellyfin)
        compose_path="$services_dir/jellyfin/docker-compose.yml"
        host=$JELLYFIN
        ;;
    media)
        compose_path="$services_dir/media/docker-compose.yml"
        host=$MEDIA
        ;;
    nginx)
        compose_path="$services_dir/nginx-proxy-manager/docker-compose.yml"
        host=$NGINX
        ;;
    pdf)
        compose_path="$services_dir/stirling-pdf/docker-compose.yml"
        host=$PDF
        ;;
    pihole)
        compose_path="$services_dir/pihole/docker-compose.yml"
        host=$PIHOLE
        ;;
    pdf)
        compose_path="$services_dir/stirling-pdf/docker-compose.yml"
        host=$PDF
        ;;
    wedding)
        compose_path="$services_dir/wedding-share/docker-compose.yml"
        host=$WEDDING
        ;;
    *)
        echo "Invalid argument"
        exit 1;;
esac

deploy
