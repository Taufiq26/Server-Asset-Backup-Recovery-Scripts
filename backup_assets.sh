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

if [ $? -eq 0 ]; then
    echo "Backup Assets successfully: $TARGET_DIR"
else
    echo "Backup Assets FAILED!"
    rm -rf "$TARGET_DIR"
    exit 1
fi

# Upload ke Google Drive (Sync folder)
echo "Syncing assets to Cloud..."
rclone copy $TARGET_DIR gdrive:backups_project_x/minio_assets/assets_$DATE

# 2. Retensi: Hanya simpan 2 folder terbaru
echo "Clean up old assets (keep the 2 newest ones)..."
# Mencari folder dengan pola 'assets_*' di dalam folder backup
ls -dt $BACKUP_BASE_DIR/assets_*/ | tail -n +3 | xargs -r rm -rf

# Hapus file di Cloud yang lebih tua dari 2 hari
# Kita list folder di GDrive, urutkan, dan hapus yang paling lama (selain 2 terbaru)
rclone lsf $GDRIVE_PATH --dirs-only | sort | head -n -2 | xargs -I {} rclone purge "$GDRIVE_PATH/{}"

echo "Finished."
