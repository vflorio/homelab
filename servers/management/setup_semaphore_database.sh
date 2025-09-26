#!/bin/bash
#
# Semaphore Database Setup Script
# Author: Generated for vflorio homelab management server
# Purpose: Create Semaphore database in PostgreSQL
#
# Usage: ./setup_semaphore_database.sh
#

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo -e "${RED}Error: .env file not found${NC}"
    exit 1
fi

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

log "Starting Semaphore Database Setup..."

# Check if PostgreSQL container is running
if ! docker ps | grep -q postgresql; then
    error "PostgreSQL container is not running. Please start it first with: docker compose up -d postgresql"
    exit 1
fi

# Wait for PostgreSQL to be ready
log "Waiting for PostgreSQL to be ready..."
timeout=60
count=0
until docker exec postgresql pg_isready -U "$POSTGRESQL_USERNAME" -d "$AUTHENTIK_DATABASE" > /dev/null 2>&1; do
    if [ $count -ge $timeout ]; then
        error "PostgreSQL is not ready after ${timeout} seconds"
        exit 1
    fi
    count=$((count + 1))
    sleep 1
done

success "PostgreSQL is ready"

# Create Semaphore database
log "Creating Semaphore database: $SEMAPHORE_DATABASE"

docker exec -i postgresql psql -U "$POSTGRESQL_USERNAME" -d "$AUTHENTIK_DATABASE" <<EOF
-- Create Semaphore database if it doesn't exist
SELECT 'CREATE DATABASE "$SEMAPHORE_DATABASE"'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$SEMAPHORE_DATABASE')\gexec

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE "$SEMAPHORE_DATABASE" TO "$POSTGRESQL_USERNAME";

-- Connect to the Semaphore database and create extensions if needed
\c $SEMAPHORE_DATABASE;

-- Semaphore will create its own tables, so we don't need to run any additional setup

EOF

if [ $? -eq 0 ]; then
    success "Semaphore database setup completed successfully!"
    echo
    log "Database Information:"
    echo "  - Database Name: $SEMAPHORE_DATABASE"
    echo "  - Username: $POSTGRESQL_USERNAME"
    echo "  - Host: postgresql (container)"
    echo "  - Port: $POSTGRESQL_PORT"
    echo
    log "You can now start Semaphore with: docker compose up -d semaphore"
    echo
    log "Access Semaphore at:"
    echo "  - Local: http://localhost:$WEBUI_PORT_SEMAPHORE"
    echo "  - Internal: http://$INTRANET_DOMAIN:$WEBUI_PORT_SEMAPHORE"
    echo "  - External: https://semaphore.$CLOUDFLARE_DNS_ZONE"
    echo
    log "Default Admin Credentials:"
    echo "  - Username: $SEMAPHORE_ADMIN_USER"
    echo "  - Email: $SEMAPHORE_ADMIN_EMAIL"
    echo "  - Password: $SEMAPHORE_ADMIN_PASSWORD"
else
    error "Failed to setup Semaphore database"
    exit 1
fi