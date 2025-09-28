#!/usr/bin/bash
set -e

FOLDER_FOR_YAMLS=./             # <-- Folder where the yaml and .env files are located

# Check if .env exists
cd $FOLDER_FOR_YAMLS

ENV_FILE=".env"
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: .env file not found in $(pwd)"
    echo "Please update the FOLDER_FOR_YAMLS=/docker location inside the restart.sh script"
    exit 1
fi


FOLDER_FOR_DATA=$(grep  -E '^FOLDER_FOR_DATA='  "$ENV_FILE" | cut -d '=' -f2- | xargs | tr -d '\r')
PUID=$(grep -E '^PUID=' "$ENV_FILE" | cut -d '=' -f2- | xargs | tr -d '\r')
PGID=$(grep -E '^PGID=' "$ENV_FILE" | cut -d '=' -f2- | xargs | tr -d '\r')

echo && echo "✅ Found the following variables / values in your $ENV_FILE file:"
echo "   - FOLDER_FOR_DATA=$FOLDER_FOR_DATA"
echo "   - PUID=$PUID"
echo "   - PGID=$PGID"

# Validate required vars
MISSING_VARS=()
[ -z "$FOLDER_FOR_DATA" ]  && MISSING_VARS+=("FOLDER_FOR_DATA")
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
sudo -E mkdir -p $FOLDER_FOR_DATA/{authentik/{certs,media,templates},crowdsec/data,ddns-updater,headplane/data,headscale/data,portainer,postgresql,tailscale,traefik/letsencrypt,traefik-certs-dumper}

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
echo Removing all non-persistent Docker containers, volumes, and networks...
echo 
if [ -n "$containers" ]; then
  sudo docker stop $containers            # Stop all active Docker containers
  sudo docker rm   $containers            # Remove all active Docker containers
fi

sudo docker container  prune -f           # Force-remove all Docker containers
#sudo docker image      prune -a -f       # Force-remove all Docker images                   <-- THIS WILL FORCE ALL DOCKER IMAGES TO BE DOWNLOADED AGAIN
sudo docker volume     prune -f           # Force-remove all non-persistent Docker volumes
sudo docker network    prune -f           # Force-remove all Docker networks

echo 
echo Moving configuration files into application folders...
echo 
sudo chmod 664                .env *yaml
sudo chown $PUID:$PGID        .env *yaml *sh
sudo touch                    $FOLDER_FOR_DATA/traefik/acme.json
sudo chmod 600                $FOLDER_FOR_DATA/traefik/acme.json && echo "Permissions set to 600 on certs file $FOLDER_FOR_DATA/traefik/acme.json"
sudo cp headplane/headplane-config.yaml $FOLDER_FOR_DATA/headplane/config.yaml         && echo "File headplane-config.yaml copied to $FOLDER_FOR_DATA/headplane/config.yaml"
sudo cp headscale/headscale-config.yaml $FOLDER_FOR_DATA/headscale/config.yaml         && echo "File headscale-config.yaml copied to $FOLDER_FOR_DATA/headscale/config.yaml"
sudo cp traefik/traefik-static.yaml   $FOLDER_FOR_DATA/traefik/traefik.yaml          && echo "File traefik-static.yaml   copied to $FOLDER_FOR_DATA/traefik/traefik.yaml"
sudo cp traefik/traefik-dynamic.yaml  $FOLDER_FOR_DATA/traefik/dynamic.yaml          && echo "File traefik-dynamic.yaml  copied to $FOLDER_FOR_DATA/traefik/dynamic.yaml"
sudo cp traefik/traefik-internal.yaml $FOLDER_FOR_DATA/traefik/internal.yaml         && echo "File traefik-internal.yaml copied to $FOLDER_FOR_DATA/traefik/internal.yaml"
sudo cp crowdsec/crowdsec-acquis.yaml  $FOLDER_FOR_DATA/crowdsec/acquis.yaml          && echo "File crowdsec-acquis.yaml  copied to $FOLDER_FOR_DATA/crowdsec/acquis.yaml"

# Subroutine below will check if Docker successully started all containers, before pruning un-used images from Docker
echo 
echo Recreating all Docker containers, volumes, and networks...
echo 
if ! docker compose up -d; then
    echo Command "'"docker compose up -d"'" failed to start containers... exiting!
    exit 1
fi

EXPECTED_SERVICES=$(docker compose config --services)
FAILED=0

for SERVICE in $EXPECTED_SERVICES; do
    STATUS=$(docker inspect --format='{{.State.Running}}' "$(docker compose ps -q $SERVICE)")
    if [[ "$STATUS" != "true" ]]; then
        echo 
        echo "Docker container $SERVICE is not running..."
        echo 
        FAILED=1
    fi
done

if [[ $FAILED -eq 0 ]]; then
    echo 
    echo "All Docker containers are running... Removing all outdated Docker images that are not being used..."
    echo 
    sudo docker image prune -a -f
else
    echo 
    echo "One or more Docker services failed to start, unused Docker images will not be deleted..."
    echo 
    exit 1
fi
