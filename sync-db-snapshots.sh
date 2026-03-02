#!/bin/bash
set -euo pipefail

source ./.env.sh
source ./.env.app.sh

# --- VALIDATION ---
if [ -z "${G_RCLONE_BACKUP_REMOTE_NAME:-}" ]; then
    echo "ERROR: G_RCLONE_BACKUP_REMOTE_NAME is not set"
    exit 1
fi
if [ -z "${APP_BACKUP_DB_BUCKET:-}" ]; then
    echo "ERROR: APP_BACKUP_DB_BUCKET is not set"
    exit 1
fi

mkdir -p "$(dirname "$G_LOG_FILE")"

# --- EXECUTION ---

# Check if local directory exists
if [ ! -d "$G_LOCAL_DB_BACKUP_DIR" ]; then
    echo "Error: Local backup directory $G_LOCAL_DB_BACKUP_DIR does not exist."
    exit 1
fi

echo "[$(date)] Starting Rclone Sync: $G_LOCAL_DB_BACKUP_DIR -> $G_RCLONE_BACKUP_REMOTE_NAME:$G_RCLONE_BACKUP_BUCKET_DB_NAME/" | tee -a "$G_LOG_FILE"

# 1. Sync files to B2/S3 using rclone
# --include "*.age" ensures only encrypted files go up.
# --fast-list reduces API calls (saves money/time).
rclone sync "$G_LOCAL_DB_BACKUP_DIR/$APP_NAME" "$G_RCLONE_BACKUP_REMOTE_NAME:$APP_BACKUP_DB_BUCKET/" \
    --include "*.age" \
    --fast-list \
    --verbose

echo "[$(date)] Sync to remote completed successfully." | tee -a "$G_LOG_FILE"

# 2. Local Cleanup
echo "[$(date)] Cleaning up local files older than $G_RETENTION_DAYS days..." | tee -a "$G_LOG_FILE"
find "$G_LOCAL_DB_BACKUP_DIR/$APP_NAME" -type f -name "*.age" -mtime +"$G_RETENTION_DAYS" -delete

echo "[$(date)] Maintenance complete." | tee -a "$G_LOG_FILE"
