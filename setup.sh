#!/usr/bin/bash
set -e

FOLDER_FOR_DATA=/mnt/ssd-0/homelab/data       

sudo -E mkdir -p $FOLDER_FOR_DATA/{authentik/{certs,media,templates},bazarr,chromium,coder,crowdsec/data,ddns-updater,filebot,gluetun,grafana,headplane/data,headscale/data,heimdall,homarr/{configs,data,icons},homepage,huntarr,jellyfin,jellyseerr,lidarr,logs/{unpackerr,traefik},mylar,plex,portainer,postgresql,prometheus,prowlarr,qbittorrent,radarr,readarr,sabnzbd,sonarr,tailscale,tdarr/{server,configs,logs},tdarr-node,traefik/letsencrypt,traefik-certs-dumper,unpackerr,valkey,whisparr}
sudo -E mkdir -p $FOLDER_FOR_DATA/media/{anime,audio,books,comics,movies,music,photos,tv,xxx}
sudo -E mkdir -p $FOLDER_FOR_DATA/usenet/{anime,audio,books,comics,complete,console,incomplete,movies,music,prowlarr,software,tv,xxx}
sudo -E mkdir -p $FOLDER_FOR_DATA/torrents/{anime,audio,books,comics,complete,console,incomplete,movies,music,prowlarr,software,tv,xxx}
sudo -E mkdir -p $FOLDER_FOR_DATA/watch
sudo -E mkdir -p $FOLDER_FOR_DATA/filebot/{input,output}