#!/bin/bash

# Set this script in crontab
# # MinIO Assets Backup every 2:30 AM
# 30 2 * * * /bin/bash /root/scripts-backup/backup_assets.sh >> /root/scripts-backup/backup_log.log 2>&1

# Configuration
SOURCE_ALIAS="local/bucket-name"
BACKUP_BASE_DIR="/var/backups/minio_assets"
DATE=$(date +%Y%m%d_%H%M%S)
TARGET_DIR="$BACKUP_BASE_DIR/assets_$DATE"

# 1. Backup Execution (Copy from MinIO to Local Folder)
echo "[$DATE] Starting asset backup from $SOURCE_ALIAS..."
mkdir -p "$TARGET_DIR"

# Using mc mirror to copy the bucket contents to the destination folder
mc mirror "$SOURCE_ALIAS" "$TARGET_DIR"

# Upload ke Google Drive (Sync folder)
echo "Syncing assets to Cloud..."
rclone copy $TARGET_DIR gdrive:backups_project_x/minio_assets/assets_$DATE

if [ $? -eq 0 ]; then
    echo "Backup Assets successfully: $TARGET_DIR"
else
    echo "Backup Assets FAILED!"
    rm -rf "$TARGET_DIR"
    exit 1
fi

# 2. Retensi: Hanya simpan 2 folder terbaru
echo "Clean up old assets (keep the 2 newest ones)..."
# Mencari folder dengan pola 'assets_*' di dalam folder backup
ls -dt $BACKUP_BASE_DIR/assets_*/ | tail -n +3 | xargs -r rm -rf

# Hapus file di Cloud yang lebih tua dari 7 hari
rclone delete gdrive:backups_project_x/minio_assets --min-age 7d --rmdirs

echo "Finished."
