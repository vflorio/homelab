#!/bin/bash
set -e

export $(cat .env | grep -v '#' | xargs)

mkdir -p "${PATH_DATA}/postgres/data"
mkdir -p "${PATH_DATA}/authentik/media" "${PATH_DATA}/authentik/templates" "${PATH_DATA}/authentik/certs"
mkdir -p "${PATH_DATA}/logs/traefik"

sudo chown -R 70:70 "${PATH_DATA}/postgres/data"
sudo chmod 700 "${PATH_DATA}/postgres/data"

echo "✅ Setup completato"
