#!/bin/bash

source ./.env.sh
source ./.env.app.sh

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

if [ $? -eq 0 ]; then
    echo "Backup saved to $LOCAL_FILE"
else
    echo "Backup failed!"
    exit 1
fi
