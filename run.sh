#!/bin/bash
# Usage: ./run.sh [reset]
# ./run.sh        – run demo (keeps existing database)
# ./run.sh reset  – wipe database and start fresh

CONTAINER="sql_demo"
DB="NearbyShopsDemo"
PW="Demo1234!"
SQLCMD="docker exec $CONTAINER /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P '$PW' -No"
DIR="$(cd "$(dirname "$0")" && pwd)"

# Reset if requested
if [ "$1" == "reset" ]; then
    echo "🗑️  Resetting database..."
    docker exec $CONTAINER /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$PW" -No \
        -Q "DROP DATABASE IF EXISTS $DB; CREATE DATABASE $DB"
fi

# Copy all SQL files into container
echo "📁 Copying SQL files..."
for f in 01_schema.sql 02_seed_data.sql 03_stored_procedures.sql 04_demo_run.sql; do
    docker cp "$DIR/$f" $CONTAINER:/tmp/
done

# Run in order
echo "🏗️  Creating schema..."
docker exec $CONTAINER /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$PW" -No -d $DB -i /tmp/01_schema.sql

echo "🌱 Seeding data..."
docker exec $CONTAINER /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$PW" -No -d $DB -i /tmp/02_seed_data.sql

echo "⚙️  Creating stored procedures..."
docker exec $CONTAINER /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$PW" -No -d $DB -i /tmp/03_stored_procedures.sql

echo "🚀 Running demo..."
docker exec $CONTAINER /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$PW" -No -W -d $DB -i /tmp/04_demo_run.sql
