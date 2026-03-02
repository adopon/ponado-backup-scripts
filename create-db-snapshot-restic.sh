#!/bin/bash
set -euo pipefail

# Database backup script using restic for encryption and compression
# Uses SQLite's .backup command for fast, consistent binary snapshots
# Usage: source .env.sh && source .env.app.sh && ./create-db-snapshot-restic.sh

# --- VALIDATION ---
if [ -z "${APP_RESTIC_REPOSITORY:-}" ]; then
    echo "ERROR: APP_RESTIC_REPOSITORY is not set"
    exit 1
fi

if [ -z "${APP_RESTIC_PASSWORD:-}" ]; then
    echo "ERROR: APP_RESTIC_PASSWORD is not set"
    exit 1
fi

if [ -z "${APP_DB_PATH:-}" ]; then
    echo "ERROR: APP_DB_PATH is not set"
    exit 1
fi

if [ -z "${APP_NAME:-}" ]; then
    echo "ERROR: APP_NAME is not set"
    exit 1
fi

# Export restic env vars
export RESTIC_REPOSITORY="$APP_RESTIC_REPOSITORY"
export RESTIC_PASSWORD="$APP_RESTIC_PASSWORD"

# Create log directory if needed
mkdir -p "$(dirname "$G_LOG_FILE")"

# Naming
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
DB_NAME=$(basename "$APP_DB_PATH")
SNAPSHOT_TAG="${APP_NAME}_${DB_NAME}_${TIMESTAMP}"

# Temp file for consistent backup
TEMP_BACKUP=$(mktemp -t "restic_backup_${DB_NAME}.XXXXXX.db")
trap 'rm -f "$TEMP_BACKUP"' EXIT

# --- EXECUTION ---
echo "Creating restic snapshot: $SNAPSHOT_TAG"

# Initialize repo if it doesn't exist (ignore error if already initialized)
restic init 2>/dev/null || true

# Create consistent database backup using SQLite's backup command
# This is faster and more reliable than .dump for binary backups
echo "Creating consistent database copy..."
sqlite3 "$APP_DB_PATH" ".backup '$TEMP_BACKUP'"

# Backup the temp file with restic
echo "Uploading to restic repository..."
restic backup "$TEMP_BACKUP" \
    --tag "$APP_NAME" \
    --tag "$DB_NAME" \
    --tag "manual"

echo "[$(date)] SUCCESS: Database backed up to restic repository" | tee -a "$G_LOG_FILE"

# Optional: Apply retention policy if G_RETENTION_DAYS is set
if [ -n "${G_RETENTION_DAYS:-}" ]; then
    echo "Applying retention policy: keeping last ${G_RETENTION_DAYS} days"
    restic forget --tag "$APP_NAME" --keep-within "${G_RETENTION_DAYS}d" --prune
    echo "[$(date)] SUCCESS: Retention policy applied" | tee -a "$G_LOG_FILE"
fi
