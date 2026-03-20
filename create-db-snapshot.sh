#!/bin/bash
set -euo pipefail

# --- VALIDATION ---
if [ -z "${APP_DB_PATH:-}" ]; then
    echo "ERROR: APP_DB_PATH is not set"
    exit 1
fi

mkdir -p "$(dirname "$G_LOG_FILE")"

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
DB_NAME=$(basename "$APP_DB_PATH")
BACKUP_NAME="${DB_NAME}_${TIMESTAMP}.sql.gz"
LOCAL_FILE="$G_LOCAL_DB_BACKUP_DIR/$APP_NAME/$BACKUP_NAME"

mkdir -p "$G_LOCAL_DB_BACKUP_DIR/$APP_NAME"

echo "Creating local snapshot: $BACKUP_NAME"
sqlite3 "$APP_DB_PATH" .dump | gzip -c > "$LOCAL_FILE"

echo "[$(date)] SUCCESS: Backup saved to $LOCAL_FILE" | tee -a "$G_LOG_FILE"
