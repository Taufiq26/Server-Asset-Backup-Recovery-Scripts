#!/bin/bash

# Set this script in crontab
# # PostgreSQL Backup every 2:00 AM
# 0 2 * * * /bin/bash /root/scripts-backup/backup_pg.sh >> /root/scripts-backup/backup_log.log 2>&1

# Konfigurasi
BACKUP_DIR="/var/backups/pg_data"
DB_NAME="db_name"
DB_USER="usr_db"
DATE=$(date +%Y%m%d_%H%M%S)
FILE_NAME="pg_backup_$DATE.sql"

# 1. Eksekusi Backup
echo "[$DATE] Starting a PostgreSQL backup: $DB_NAME..."
pg_dump -U $DB_USER -h localhost $DB_NAME > $BACKUP_DIR/$FILE_NAME

if [ $? -eq 0 ]; then
    echo "PostgreSQL backup successful: $FILE_NAME"
else
    echo "PostgreSQL Backup FAILED!"
    exit 1
fi

# 2. Retensi: Simpan 7 file terbaru
echo "Cleaning up old backups (keeping the latest 7)..."
ls -t $BACKUP_DIR/pg_backup_*.sql | tail -n +8 | xargs -r rm

echo "Finished."
