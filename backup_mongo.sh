#!/bin/bash

# Set this script in crontab
# # MongoDB Backup every 2:15 AM
# 15 2 * * * /bin/bash /root/scripts-backup/backup_mongo.sh >> /root/scripts-backup/backup_log.log 2>&1

# Configuration
BACKUP_DIR="/var/backups/mongo_data"
DB_NAME="kbp-page-editor"
DATE=$(date +%Y%m%d_%H%M%S)
FILE_NAME="mongo_backup_$DATE.gz"

# Kredensial (Gunakan tanda petik tunggal untuk password)
MONGO_USER='kbp_page_editor'
MONGO_PASS='@p1455woRD!#' # Ganti dengan password asli
AUTH_DB="kbp-page-editor"

# 1. Eksekusi Backup
echo "[$DATE] Memulai backup MongoDB: $DB_NAME..."
mongodump --db="$DB_NAME" \
          --username="$MONGO_USER" \
          --password="$MONGO_PASS" \
          --authenticationDatabase="$AUTH_DB" \
          --archive="$BACKUP_DIR/$FILE_NAME" \
          --gzip

if [ $? -eq 0 ]; then
    echo "Backup MongoDB berhasil: $FILE_NAME"
else
    echo "Backup MongoDB GAGAL!"
    exit 1
fi

# 2. Retention: Keep the 7 most recent files
echo "Membersihkan backup lama (menyimpan 7 terbaru)..."
ls -t $BACKUP_DIR/mongo_backup_*.gz | tail -n +8 | xargs -r rm 2>/dev/null

echo "Selesai."
