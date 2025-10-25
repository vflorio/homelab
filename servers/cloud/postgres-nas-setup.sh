#!/bin/bash
set -e

export $(cat .env | grep -v '#' | xargs)

mkdir -p "${PATH_DATA}/postgres/nextcloud/data"
mkdir -p "${PATH_DATA}/postgres/immich/data"
mkdir -p "${PATH_DATA}/postgres/backups"

sudo chown -R 70:70 "${PATH_DATA}/postgres/nextcloud/data"
sudo chmod 700 "${PATH_DATA}/postgres/nextcloud/data"

sudo chown -R 70:70 "${PATH_DATA}/postgres/immich/data"
sudo chmod 700 "${PATH_DATA}/postgres/immich/data"

echo "✅ Setup completato"
