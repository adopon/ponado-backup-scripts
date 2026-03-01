#!/bin/bash

source ./.env.sh
source ./.env.app.sh

# --- EXECUTION ---

# Check if local directory exists
if [ ! -d "$G_LOCAL_DB_BACKUP_DIR" ]; then
    echo "Error: Local backup directory $G_LOCAL_DB_BACKUP_DIR does not exist."
    exit 1
fi

echo "Starting Rclone Sync: $G_LOCAL_DB_BACKUP_DIR -> $G_RCLONE_BACKUP_REMOTE_NAME:$G_RCLONE_BACKUP_BUCKET_DB_NAME/"

# 1. Sync files to B2/S3 using rclone
# --include "*.age" ensures only encrypted files go up.
# --fast-list reduces API calls (saves money/time).
rclone sync "$G_LOCAL_DB_BACKUP_DIR/$APP_NAME" "$G_RCLONE_BACKUP_REMOTE_NAME:$APP_BACKUP_DB_BUCKET/" \
    --include "*.age" \
    --fast-list \
    --verbose

# Check if the rclone command succeeded
if [ $? -eq 0 ]; then
    echo "Sync to remote completed successfully."

    # 2. Local Cleanup
    echo "Cleaning up local files older than $G_RETENTION_DAYS days..."
    find "$G_LOCAL_DB_BACKUP_DIR/$APP_NAME" -type f -name "*.age" -mtime +$G_RETENTION_DAYS -delete

    echo "Maintenance complete."
else
    echo "Error: Rclone Sync failed. Check your rclone config and permissions."
    exit 1
fi
