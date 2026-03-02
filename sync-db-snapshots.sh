#!/bin/bash
set -euo pipefail

# sourcing for debug purposes
# it should be sourced in wrapper script

# source .env.sh
# source .env.app.sh

# --- VALIDATION ---
if [ -z "${APP_RCLONE_BACKUP_REMOTE:-}" ]; then
    echo "ERROR: APP_RCLONE_BACKUP_REMOTE is not set"
    exit 1
fi
if [ -z "${APP_DB_BACKUP_BUCKET:-}" ]; then
    echo "ERROR: APP_DB_BACKUP_BUCKET is not set"
    exit 1
fi

mkdir -p "$(dirname "$G_LOG_FILE")"

# --- EXECUTION ---

# Check if local directory exists
if [ ! -d "$G_LOCAL_DB_BACKUP_DIR" ]; then
    echo "Error: Local backup directory $G_LOCAL_DB_BACKUP_DIR does not exist."
    exit 1
fi

echo "[$(date)] Starting Rclone Sync: $G_LOCAL_DB_BACKUP_DIR -> $APP_RCLONE_BACKUP_REMOTE:$APP_DB_BACKUP_BUCKET/" | tee -a "$G_LOG_FILE"

# 1. Sync files to B2/S3 using rclone
# --include "*.age" ensures only encrypted files go up.
# --fast-list reduces API calls (saves money/time).
rclone sync "$G_LOCAL_DB_BACKUP_DIR/$APP_NAME" "$APP_RCLONE_BACKUP_REMOTE:$APP_DB_BACKUP_BUCKET/" \
    --include "*.age" \
    --fast-list \
    --verbose

echo "[$(date)] Sync to remote completed successfully." | tee -a "$G_LOG_FILE"

# 2. Local Cleanup
echo "[$(date)] Cleaning up local files older than $G_RETENTION_DAYS days..." | tee -a "$G_LOG_FILE"
find "$G_LOCAL_DB_BACKUP_DIR/$APP_NAME" -type f -name "*.age" -mtime +"$G_RETENTION_DAYS" -delete

echo "[$(date)] Maintenance complete." | tee -a "$G_LOG_FILE"
