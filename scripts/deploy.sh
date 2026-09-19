#!/bin/bash
set -euo pipefail

script_dir=$(dirname "$(realpath "$0")")
services_dir="$script_dir/../services"

deploy () {
    ssh "$host" "mkdir -p /docker"
    scp "$compose_path" "$host:/docker"

    ssh "$host" "cd /docker && docker compose up -d --remove-orphans"
}

all_services='jellyfin media nginx-proxy-manager pihole stirling-pdf'

if [ $# -eq 0 ]; then
    echo "Usage: $(basename "$0") all | <service>... ($all_services)" >&2
    exit 1
fi

# "all" stands in for every service; compose leaves unchanged ones alone.
services=
for arg in "$@"; do
    if [ "$arg" = all ]; then services="$services $all_services"; else services="$services $arg"; fi
done

for service in $services; do
    case $service in
        jellyfin)
            compose_path="$services_dir/jellyfin/docker-compose.yml"
            host=$JELLYFIN
            ;;
        media)
            compose_path="$services_dir/media/docker-compose.yml"
            host=$MEDIA
            ;;
        nginx|nginx-proxy-manager)
            compose_path="$services_dir/nginx-proxy-manager/docker-compose.yml"
            host=$NGINX
            ;;
        pdf|stirling-pdf)
            compose_path="$services_dir/stirling-pdf/docker-compose.yml"
            host=$PDF
            ;;
        pihole)
            compose_path="$services_dir/pihole/docker-compose.yml"
            host=$PIHOLE
            ;;
        *)
            echo "Invalid argument: $service" >&2
            exit 1;;
    esac

    echo "Deploying $service to $host"
    deploy
done
