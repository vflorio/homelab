#!/usr/bin/bash
set -e

###########################################################################
# HomeLab Media Server Start Script
# srv-media.intranet.vflorio.com (192.168.1.172)
###########################################################################

FOLDER_FOR_YAMLS=./             # <-- Folder where the yaml and .env files are located

# Check if .env exists
cd $FOLDER_FOR_YAMLS

ENV_FILE=".env"
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: .env file not found in $(pwd)"
    echo "Please update the FOLDER_FOR_YAMLS location inside the start.sh script"
    exit 1
fi

# Read values from .env and clean them
FOLDER_FOR_MEDIA=$(grep -E '^FOLDER_FOR_MEDIA=' "$ENV_FILE" | cut -d '=' -f2- | xargs | tr -d '\r')
FOLDER_FOR_DATA=$(grep  -E '^FOLDER_FOR_DATA='  "$ENV_FILE" | cut -d '=' -f2- | xargs | tr -d '\r')
FOLDER_FOR_CONFIGS=$(grep  -E '^FOLDER_FOR_CONFIGS='  "$ENV_FILE" | cut -d '=' -f2- | xargs | tr -d '\r')
FOLDER_FOR_DOWNLOADS=$(grep  -E '^FOLDER_FOR_DOWNLOADS='  "$ENV_FILE" | cut -d '=' -f2- | xargs | tr -d '\r')
PUID=$(grep -E '^PUID=' "$ENV_FILE" | cut -d '=' -f2- | xargs | tr -d '\r')
PGID=$(grep -E '^PGID=' "$ENV_FILE" | cut -d '=' -f2- | xargs | tr -d '\r')

echo && echo "✅ Found the following variables / values in your $ENV_FILE file:"
echo "   - FOLDER_FOR_MEDIA=$FOLDER_FOR_MEDIA"
echo "   - FOLDER_FOR_DATA=$FOLDER_FOR_DATA"
echo "   - FOLDER_FOR_CONFIGS=$FOLDER_FOR_CONFIGS"
echo "   - FOLDER_FOR_DOWNLOADS=$FOLDER_FOR_DOWNLOADS"
echo "   - PUID=$PUID"
echo "   - PGID=$PGID"

# Validate required vars
MISSING_VARS=()
[ -z "$FOLDER_FOR_MEDIA" ] && MISSING_VARS+=("FOLDER_FOR_MEDIA")
[ -z "$FOLDER_FOR_DATA" ]  && MISSING_VARS+=("FOLDER_FOR_DATA")
[ -z "$FOLDER_FOR_CONFIGS" ]  && MISSING_VARS+=("FOLDER_FOR_CONFIGS")
[ -z "$FOLDER_FOR_DOWNLOADS" ]  && MISSING_VARS+=("FOLDER_FOR_DOWNLOADS")
[ -z "$PUID" ] && MISSING_VARS+=("PUID")
[ -z "$PGID" ] && MISSING_VARS+=("PGID")

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
    echo "❌ Error: The following required variables are missing or empty in $ENV_FILE:"
    for var in "${MISSING_VARS[@]}"; do
        echo "   - $var"
    done
    exit 1
fi

echo 
echo Creating folders and setting permissions...
echo 

cd $FOLDER_FOR_YAMLS

# Create media-specific application config directories
sudo -E mkdir -p $FOLDER_FOR_CONFIGS/{bazarr,filebot,jellyfin,jellyseerr,lidarr,qbittorrent,prowlarr,radarr,readarr,sabnzbd,sonarr,tdarr/{server,configs,logs},unpackerr}

# Create media library directories
sudo -E mkdir -p $FOLDER_FOR_MEDIA/{tv,movies,music,books,filebot/{input,output}}

# Create download directories  
sudo -E mkdir -p $FOLDER_FOR_DOWNLOADS/{complete,incomplete,torrents/{complete,incomplete},usenet/{complete,incomplete},transcode_cache}

# Set permissions
sudo -E chmod -R 2775 $FOLDER_FOR_MEDIA $FOLDER_FOR_CONFIGS $FOLDER_FOR_DOWNLOADS
sudo -E chown -R $PUID:$PGID $FOLDER_FOR_MEDIA $FOLDER_FOR_CONFIGS $FOLDER_FOR_DOWNLOADS

# This checks for missing variables and invalid docker compose configuration
echo 
echo Validating Docker Compose configuration...
echo 
if ! docker compose config > /dev/null; then
    echo 
    echo Docker Compose configuration is invalid or missing required variables...
    echo 
    exit 1
fi

# Download all Docker images - will also pull newer / updated images if they exist
echo 
echo Pulling new / updated Docker images...
echo 
sudo docker compose pull

echo 
echo Removing existing media server containers...
echo 
containers=$(sudo docker ps -a --filter "label=com.docker.compose.project=media" -q)
if [ -n "$containers" ]; then
  sudo docker stop $containers            # Stop all media server Docker containers
  sudo docker rm   $containers            # Remove all media server Docker containers
fi

echo 
echo Setting up configuration files...
echo 
sudo chmod 664                .env *yaml
sudo chown $PUID:$PGID        .env *yaml *sh

# Subroutine below will check if Docker successfully started all containers
echo 
echo Starting all Docker containers...
echo 
if ! docker compose up -d; then
    echo Command "'"docker compose up -d"'" failed to start containers... exiting!
    exit 1
fi

EXPECTED_SERVICES=$(docker compose config --services)
FAILED=0

echo 
echo Checking container health...
echo 

for SERVICE in $EXPECTED_SERVICES; do
    STATUS=$(docker inspect --format='{{.State.Running}}' "$(docker compose ps -q $SERVICE)" 2>/dev/null || echo "false")
    if [[ "$STATUS" != "true" ]]; then
        echo "❌ Docker container $SERVICE is not running..."
        FAILED=1
    else
        echo "✅ Docker container $SERVICE is running"
    fi
done

if [[ $FAILED -eq 0 ]]; then
    echo 
    echo "✅ All Docker containers are running successfully!"
    echo "🔗 Access your media services:"
    echo "   - Jellyfin: https://jellyfin.intranet.vflorio.com"
    echo "   - Jellyseerr: https://requests.intranet.vflorio.com"
    echo "   - Sonarr: https://sonarr.intranet.vflorio.com"
    echo "   - Radarr: https://radarr.intranet.vflorio.com"
    echo "   - Prowlarr: https://prowlarr.intranet.vflorio.com"
    echo "   - qBittorrent: https://torrent.intranet.vflorio.com"
    echo 
    sudo docker image prune -a -f
else
    echo 
    echo "❌ One or more Docker services failed to start..."
    echo 
    exit 1
fi