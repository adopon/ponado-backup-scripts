#!/bin/bash
set -euo pipefail

# --- CONFIGURATION ---
SOURCE="${APP_RCLONE_LOCAL_REMOTE:-}:${APP_UPLOADS_BUCKET:-}"
DEST="${APP_RCLONE_BACKUP_REMOTE:-}:${APP_UPLOADS_BACKUP_BUCKET:-}"

mkdir -p "$(dirname "$G_LOG_FILE")"

# Quiet options
OPTIONS="--fast-list --transfers 32 --checksum --log-level ERROR --stats=0"

echo "[$(date)] Starting sync from MinIO to B2..." >> "$G_LOG_FILE"

if rclone sync "$SOURCE" "$DEST" $OPTIONS >> "$G_LOG_FILE" 2>&1; then
    echo "[$(date)] SUCCESS: Sync completed." >> "$G_LOG_FILE"
else
    echo "[$(date)] ERROR: Sync failed." >> "$G_LOG_FILE"
    exit 1
fi
