#!/bin/bash
set -euo pipefail

source ./.env.sh
source ./.env.app.sh

# --- VALIDATION ---
if [ -z "${G_AGE_RECIPIENT:-}" ]; then
    echo "ERROR: G_AGE_RECIPIENT is not set"
    exit 1
fi
if [ -z "${APP_DB_PATH:-}" ]; then
    echo "ERROR: APP_DB_PATH is not set"
    exit 1
fi

# Create log directory if needed
mkdir -p "$(dirname "$G_LOG_FILE")"

# Naming
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
DB_NAME=$(basename "$APP_DB_PATH")
BACKUP_NAME="${DB_NAME}_${TIMESTAMP}.sql.gz.age"
LOCAL_FILE="$G_LOCAL_DB_BACKUP_DIR/$APP_NAME/$BACKUP_NAME"

# --- EXECUTION ---
mkdir -p "$G_LOCAL_DB_BACKUP_DIR/$APP_NAME"

echo "Creating encrypted local snapshot: $BACKUP_NAME"

# Stream: Dump -> Gzip -> Age
sqlite3 "$APP_DB_PATH" .dump | \
gzip -c | \
age -r "$G_AGE_RECIPIENT" -o "$LOCAL_FILE"

echo "[$(date)] SUCCESS: Backup saved to $LOCAL_FILE" | tee -a "$G_LOG_FILE"
