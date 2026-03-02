#!/bin/bash
set -euo pipefail

# --- VALIDATION ---
# Ensure these match your encryption environment variables
if [ -z "${G_AGE_KEY_FILE:-}" ]; then
    echo "ERROR: G_AGE_KEY_FILE (path to your private key) is not set"
    exit 1
fi
if [ -z "${G_LOCAL_DB_BACKUP_DIR:-}" ] || [ -z "${APP_NAME:-}" ]; then
    echo "ERROR: Backup directory variables are not set"
    exit 1
fi

BACKUP_DIR="$G_LOCAL_DB_BACKUP_DIR/$APP_NAME"

# --- FILE SELECTION ---
# If an argument is passed ($1), use it. Otherwise, find the latest .age file.
if [ "${1:-}" ] && [ -f "$1" ]; then
    SELECTED_FILE="$1"
    echo "Using provided file: $SELECTED_FILE"
else
    echo "No file provided, searching for latest backup in $BACKUP_DIR..."
    
    # Finds files, sorts by time (newest first), takes the top 1
    SELECTED_FILE=$(ls -t "$BACKUP_DIR"/*.age 2>/dev/null | head -n 1)

    if [ -z "$SELECTED_FILE" ]; then
        echo "ERROR: No backup files found in $BACKUP_DIR"
        exit 1
    fi
    echo "Found latest backup: $(basename "$SELECTED_FILE")"
fi

# --- PREPARE TARGET ---
# Create a temp directory for the restoration
TMP_DIR=$(mktemp -d -t "restore_${APP_NAME}_XXXXXX")
# Strip .age and .gz to get the base db name
DB_BASE_NAME=$(basename "$SELECTED_FILE" .sql.gz.age)
TARGET_DB="$TMP_DIR/${DB_BASE_NAME}.db"

echo "Restoring to temporary location: $TARGET_DB"

# --- EXECUTION (Stream: Age -> Gzip -> Sqlite) ---
# Note: We use 'zcat' or 'gzip -d' to decompress the stream
age --decrypt -i "$G_AGE_KEY_FILE" "$SELECTED_FILE" | \
gzip -d -c | \
sqlite3 "$TARGET_DB"

# --- VERIFICATION ---
if [ -f "$TARGET_DB" ]; then
    echo "------------------------------------------------"
    echo "SUCCESS: Database restored to $TARGET_DB"
    echo "Size: $(du -h "$TARGET_DB" | cut -f1)"
    echo "------------------------------------------------"
    # Optional: Keep the shell open or print a success message
else
    echo "ERROR: Restoration failed."
    rm -rf "$TMP_DIR"
    exit 1
fi
