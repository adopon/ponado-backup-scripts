# Global config env:

```
export G_HOME=""
export G_SCRIPT_PATH=""
export G_AGE_RECIPIENT=""
export G_AGE_KEY_FILE=""     # optional used only for restoring encrypted snapshot
export G_LOCAL_DB_BACKUP_DIR=""
export G_RCLONE_BACKUP_REMOTE_NAME=""
export G_RETENTION_DAYS=""
export G_LOG_FILE=""
```
# App config env:

```
export APP_NAME=""
export APP_DB_PATH=""
export APP_DB_BACKUP_BUCKET=""
export APP_UPLOADS_BACKUP_BUCKET=""
export APP_UPLOADS_BUCKET=""
export APP_RCLONE_LOCAL_REMOTE=""
export APP_RCLONE_BACKUP_REMOTE=""

# Restic backup configuration (for create-db-snapshot-restic.sh)
export APP_RESTIC_REPOSITORY=""    # e.g., "s3:s3.amazonaws.com/bucket-name/app-name"
export APP_RESTIC_PASSWORD=""      # encryption password for this app's restic repo
```
