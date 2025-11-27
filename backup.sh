#!/bin/bash

# Backup Script for Production
set -e

BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "=========================================="
echo "Creating Backup - $TIMESTAMP"
echo "=========================================="

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Load environment
if [ -f .env ]; then
    source .env
fi

# Backup database
echo "Backing up database..."
if [ -f "student_platform.db" ]; then
    cp student_platform.db "$BACKUP_DIR/database_$TIMESTAMP.db"
    echo "✓ SQLite database backed up"
elif [ ! -z "$DATABASE_URL" ] && [[ $DATABASE_URL == postgresql* ]]; then
    pg_dump "$DATABASE_URL" > "$BACKUP_DIR/database_$TIMESTAMP.sql"
    echo "✓ PostgreSQL database backed up"
fi

# Backup data directory
if [ -d "data" ]; then
    tar -czf "$BACKUP_DIR/data_$TIMESTAMP.tar.gz" data/
    echo "✓ Data directory backed up"
fi

# Backup logs
if [ -d "logs" ]; then
    tar -czf "$BACKUP_DIR/logs_$TIMESTAMP.tar.gz" logs/
    echo "✓ Logs backed up"
fi

# Backup configuration
cp .env "$BACKUP_DIR/env_$TIMESTAMP.bak" 2>/dev/null || echo "⚠ No .env file to backup"

# Clean old backups (keep last 7 days)
find "$BACKUP_DIR" -name "*.db" -mtime +7 -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete 2>/dev/null || true

echo ""
echo "✓ Backup completed: $BACKUP_DIR"
ls -lh "$BACKUP_DIR" | tail -5
