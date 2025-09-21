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
AUTHENTIK_DATABASE=$(grep  -E '^AUTHENTIK_DATABASE='  "$ENV_FILE" | cut -d '=' -f2- | xargs | tr -d '\r')
POSTGRESQL_USERNAME=$(grep -E '^POSTGRESQL_USERNAME=' "$ENV_FILE" | cut -d '=' -f2- | xargs | tr -d '\r')
POSTGRESQL_PASSWORD=$(grep -E '^POSTGRESQL_PASSWORD=' "$ENV_FILE" | cut -d '=' -f2- | xargs | tr -d '\r')

echo "✅ Found the following variables / values:"
echo "   - AUTHENTIK_DATABASE=$AUTHENTIK_DATABASE"
echo "   - POSTGRESQL_USERNAME=$POSTGRESQL_USERNAME"
echo "   - POSTGRESQL_PASSWORD=$POSTGRESQL_PASSWORD"

# Validate required vars
MISSING_VARS=()
[ -z "$AUTHENTIK_DATABASE" ]  && MISSING_VARS+=("AUTHENTIK_DATABASE")
[ -z "$POSTGRESQL_USERNAME" ] && MISSING_VARS+=("POSTGRESQL_USERNAME")
[ -z "$POSTGRESQL_PASSWORD" ] && MISSING_VARS+=("POSTGRESQL_PASSWORD")

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
    echo "❌ Error: The following required variables are missing or empty in $ENV_FILE:"
    for var in "${MISSING_VARS[@]}"; do
        echo "   - $var"
    done
    exit 1
fi

# Check if database exists
echo "🔍 Checking if database '$AUTHENTIK_DATABASE' already exists..."
if sudo docker exec -e PGPASSWORD="$POSTGRESQL_PASSWORD" "$POSTGRESQL_CONTAINER" \
    psql -U "$POSTGRESQL_USERNAME" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$AUTHENTIK_DATABASE';" | grep -q 1; then
    echo "✅ Database '$AUTHENTIK_DATABASE' exists, securing with permissions."
else
    echo "❌ Error: Database '$AUTHENTIK_DATABASE' not found in container '$POSTGRESQL_CONTAINER'."
    exit 1
fi

# Grant permissions to database
sudo docker exec -e PGPASSWORD="$ADMIN_PASSWORD" -i "$POSTGRESQL_CONTAINER" psql -U "$POSTGRESQL_USERNAME" -d "$AUTHENTIK_DATABASE" <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$POSTGRESQL_USERNAME') THEN
      CREATE USER "$POSTGRESQL_USERNAME" WITH PASSWORD '$POSTGRESQL_PASSWORD';
   END IF;
END
\$\$;

GRANT CONNECT ON DATABASE "$AUTHENTIK_DATABASE" TO "$POSTGRESQL_USERNAME";
GRANT USAGE ON SCHEMA public TO "$POSTGRESQL_USERNAME";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "$POSTGRESQL_USERNAME";
GRANT SELECT, USAGE ON ALL SEQUENCES IN SCHEMA public TO "$POSTGRESQL_USERNAME";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "$POSTGRESQL_USERNAME";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO "$POSTGRESQL_USERNAME";
EOF

echo 
echo 
sudo docker exec postgresql psql -U "$POSTGRESQL_USERNAME" -l
echo 
