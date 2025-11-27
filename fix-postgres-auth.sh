#!/bin/bash

# Fix PostgreSQL Authentication
echo "Fixing PostgreSQL authentication..."

# Backup original config
sudo cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.backup

# Update pg_hba.conf to use md5 authentication
sudo bash -c 'cat > /var/lib/pgsql/data/pg_hba.conf << EOF
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     md5
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     md5
host    replication     all             127.0.0.1/32            md5
host    replication     all             ::1/128                 md5
EOF'

echo "✓ PostgreSQL config updated"

# Restart PostgreSQL
sudo systemctl restart postgresql
echo "✓ PostgreSQL restarted"

# Wait for PostgreSQL to start
sleep 3

# Test connection
echo ""
echo "Testing database connection..."
psql -U admin -d vgu -h localhost -c "SELECT version();" 2>/dev/null && echo "✓ Connection successful!" || echo "⚠ Connection test - you'll be prompted for password"

echo ""
echo "Now run: python3.11 -c 'from database import init_db; init_db()'"
