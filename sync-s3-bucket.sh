#!/bin/bash

source .env.sh
source .env.app.sh

# --- CONFIGURATION ---
SOURCE="$G_RCLONE_LOCAL_REMOTE_NAME:$APP_RCLONE_LOCAL_BUCKET"
DEST="$G_RCLONE_BACKUP_REMOTE_NAME:$APP_RCLONE_REMOTE_BUCKET"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$G_LOG_FILE")"

# --- PERFORMANCE TUNING ---
OPTIONS="--fast-list --transfers 32 --checksum"

echo "[$(date)] Starting sync from MinIO to B2..." >> "$G_LOG_FILE"

# --- EXECUTION ---
rclone sync "$SOURCE" "$DEST" $OPTIONS >> "$G_LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    echo "[$(date)] SUCCESS: Sync completed." >> "$G_LOG_FILE"
else
    echo "[$(date)] ERROR: Sync failed. Check logs." >> "$G_LOG_FILE"
    exit 1
fi
