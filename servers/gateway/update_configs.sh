#!/usr/bin/env bash
set -e

ENV_FILE=".env"
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: .env file not found in $(pwd)"
     exit 1
fi

PATH_DATA=$(grep  -E '^PATH_DATA='  "$ENV_FILE" | cut -d '=' -f2- | xargs | tr -d '\r')

echo 
echo Moving configuration files into application folders...
echo 
sudo touch $PATH_DATA/traefik/letsencrypt/acme.json
sudo cp headplane/headplane-config.yaml $PATH_DATA/headplane/config.yaml        
sudo cp headscale/headscale-config.yaml $PATH_DATA/headscale/config.yaml        
sudo cp traefik/traefik-static.yaml $PATH_DATA/traefik/traefik.yaml         
sudo cp traefik/traefik-dynamic.yaml $PATH_DATA/traefik/dynamic.yaml         
sudo cp traefik/traefik-internal.yaml $PATH_DATA/traefik/internal.yaml        
sudo cp crowdsec/crowdsec-acquis.yaml $PATH_DATA/crowdsec/acquis.yaml         
