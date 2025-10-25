#!/bin/bash
set -e

export $(cat .env | grep -v '#' | xargs)

mkdir -p "${PATH_DATA}/postgres/data"
mkdir -p "${PATH_DATA}/postgres/backups"

sudo chown -R 70:70 "${PATH_DATA}/postgres/data"
sudo chmod 700 "${PATH_DATA}/postgres/data"

echo "✅ Setup completato"
