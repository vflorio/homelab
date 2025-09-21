#!/usr/bin/env bash
set -e

POSTGRESQL_CONTAINER="postgresql"
ENV_FILE=".env"

# Check if .env exists
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: .env file not found in $(pwd)"
    exit 1
fi

# Read values from .env and clean them
GUACAMOLE_DATABASE=$(grep  -E '^GUACAMOLE_DATABASE='  "$ENV_FILE" | cut -d '=' -f2- | xargs | tr -d '\r')
POSTGRESQL_USERNAME=$(grep -E '^POSTGRESQL_USERNAME=' "$ENV_FILE" | cut -d '=' -f2- | xargs | tr -d '\r')
POSTGRESQL_PASSWORD=$(grep -E '^POSTGRESQL_PASSWORD=' "$ENV_FILE" | cut -d '=' -f2- | xargs | tr -d '\r')

echo "✅ Found the following variables / values:"
echo "   - GUACAMOLE_DATABASE=$GUACAMOLE_DATABASE"
echo "   - POSTGRESQL_USERNAME=$POSTGRESQL_USERNAME"
echo "   - POSTGRESQL_PASSWORD=$POSTGRESQL_PASSWORD"

# Validate required vars
MISSING_VARS=()
[ -z "$GUACAMOLE_DATABASE" ]  && MISSING_VARS+=("GUACAMOLE_DATABASE")
[ -z "$POSTGRESQL_USERNAME" ] && MISSING_VARS+=("POSTGRESQL_USERNAME")
[ -z "$POSTGRESQL_PASSWORD" ] && MISSING_VARS+=("POSTGRESQL_PASSWORD")

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
    echo "❌ Error: The following required variables are missing or empty in $ENV_FILE:"
    for var in "${MISSING_VARS[@]}"; do
        echo "   - $var"
    done
    exit 1
fi

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL container to be ready..."
until sudo docker exec "$POSTGRESQL_CONTAINER" pg_isready -U "$POSTGRESQL_USERNAME" > /dev/null 2>&1; do
    sleep 2
done

# Check if Guacamole database exists
echo "🔍 Checking if database '$GUACAMOLE_DATABASE' already exists..."
if sudo docker exec -e PGPASSWORD="$POSTGRESQL_PASSWORD" "$POSTGRESQL_CONTAINER" \
    psql -U "$POSTGRESQL_USERNAME" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$GUACAMOLE_DATABASE';" | grep -q 1; then
    echo "✅ Database '$GUACAMOLE_DATABASE' already exists."
else
    echo "📊 Creating database '$GUACAMOLE_DATABASE'..."
    sudo docker exec -e PGPASSWORD="$POSTGRESQL_PASSWORD" "$POSTGRESQL_CONTAINER" \
        psql -U "$POSTGRESQL_USERNAME" -d postgres -c "CREATE DATABASE \"$GUACAMOLE_DATABASE\";"
    
    echo "🔧 Setting up Guacamole database schema..."
    # Get Guacamole database schema from container
    sudo docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgresql > /tmp/guacamole_initdb.sql
    
    # Import schema into database
    sudo docker exec -i -e PGPASSWORD="$POSTGRESQL_PASSWORD" "$POSTGRESQL_CONTAINER" \
        psql -U "$POSTGRESQL_USERNAME" -d "$GUACAMOLE_DATABASE" < /tmp/guacamole_initdb.sql
    
    # Clean up temporary file
    rm -f /tmp/guacamole_initdb.sql
    
    echo "✅ Guacamole database '$GUACAMOLE_DATABASE' created and configured successfully!"
fi

echo "🎉 Guacamole database setup completed!"