#!/bin/bash
set -euo pipefail

# Sync local directory directly to remote (no snapshot creation)
# Requires: APP_BACKUP_SOURCE_DIR, APP_BACKUP_BUCKET, APP_RCLONE_BACKUP_REMOTE

# --- VALIDATION ---
if [ -z "${APP_BACKUP_SOURCE_DIR:-}" ]; then
    echo "ERROR: APP_BACKUP_SOURCE_DIR is not set"
    exit 1
fi
if [ -z "${APP_RCLONE_BACKUP_REMOTE:-}" ]; then
    echo "ERROR: APP_RCLONE_BACKUP_REMOTE is not set"
    exit 1
fi
if [ -z "${APP_BACKUP_BUCKET:-}" ]; then
    echo "ERROR: APP_BACKUP_BUCKET is not set"
    exit 1
fi

mkdir -p "$(dirname "$G_LOG_FILE")"

# --- EXECUTION ---
if [ ! -d "$APP_BACKUP_SOURCE_DIR" ]; then
    echo "Error: Source directory $APP_BACKUP_SOURCE_DIR does not exist."
    exit 1
fi

echo "[$(date)] Starting sync: $APP_BACKUP_SOURCE_DIR -> $APP_RCLONE_BACKUP_REMOTE:$APP_BACKUP_BUCKET/" | tee -a "$G_LOG_FILE"

rclone sync "$APP_BACKUP_SOURCE_DIR" "$APP_RCLONE_BACKUP_REMOTE:$APP_BACKUP_BUCKET/" \
    --fast-list \
    --verbose

echo "[$(date)] Sync completed successfully." | tee -a "$G_LOG_FILE"
