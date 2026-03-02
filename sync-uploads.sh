#!/bin/bash
set -euo pipefail

# --- CONFIGURATION ---
SOURCE="${APP_RCLONE_LOCAL_REMOTE:-}:${APP_UPLOADS_BUCKET:-}"
DEST="${APP_RCLONE_BACKUP_REMOTE:-}:${APP_UPLOADS_BACKUP_BUCKET:-}"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$G_LOG_FILE")"

# --- PERFORMANCE TUNING ---
# Added -P to show real-time progress in the console
OPTIONS="--fast-list --transfers 32 --checksum -P"

echo "[$(date)] Starting sync from MinIO to B2..." | tee -a "$G_LOG_FILE"

# --- EXECUTION ---
# 2>&1 merges errors into the same stream so tee captures everything
if rclone sync "$SOURCE" "$DEST" $OPTIONS 2>&1 | tee -a "$G_LOG_FILE"; then
    echo "[$(date)] SUCCESS: Sync completed." | tee -a "$G_LOG_FILE"
else
    echo "[$(date)] ERROR: Sync failed. Check logs." | tee -a "$G_LOG_FILE"
    exit 1
fi
