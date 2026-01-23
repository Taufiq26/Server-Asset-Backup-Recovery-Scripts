#!/bin/bash

# --- KONFIGURASI ---
PG_BACKUP_DIR="/var/backups/pg_data"
MONGO_BACKUP_DIR="/var/backups/mongo_data"
MINIO_BACKUP_DIR="/var/backups/minio_assets"

# Kredensial Admin untuk Restore
PG_USER="pg_usr_db"
MONGO_USER="admin"
MONGO_AUTH_DB="admin"

echo "=========================================="
echo "             RESTORE MANAGER              "
echo "=========================================="
echo "1. Restore PostgreSQL"
echo "2. Restore MongoDB"
echo "3. Restore MinIO Assets"
echo "4. Exit"
read -p "Select the service you want to restore [1-4]: " CHOICE

case $CHOICE in
    1)
        echo -e "\n--- PostgreSQL Backup List ---"
        ls -1 $PG_BACKUP_DIR
        read -p "Enter file name (e.g. backup_db_name.sql): " FILE
        read -p "Enter the DESTINATION database name (BE CAREFUL!): " TARGET_DB
        psql -U $PG_USER -h localhost -d $TARGET_DB < $PG_BACKUP_DIR/$FILE
        ;;
    2)
        echo -e "\n--- MongoDB Backup List ---"
        ls -1 $MONGO_BACKUP_DIR
        read -p "Enter file name (e.g. backup_db.gz): " FILE
        read -p "Enter the ORIGINAL database name (in the backup): " FROM_DB
        read -p "Enter the DESTINATION database name: " TO_DB
        read -s -p "Enter Admin password: " MONGO_PASS
        echo -e "\nStarting restore..."
        mongorestore --nsInclude="$FROM_DB.*" \
                     --nsFrom="$FROM_DB.*" \
                     --nsTo="$TO_DB.*" \
                     --username="$MONGO_USER" \
                     --password="$MONGO_PASS" \
                     --authenticationDatabase="$MONGO_AUTH_DB" \
                     --archive=$MONGO_BACKUP_DIR/$FILE \
                     --gzip
        ;;
    3)
        echo -e "\n--- Assets Backup List ---"
        ls -1 $MINIO_BACKUP_DIR
        read -p "Enter a folder name (e.g. assets_2026...): " FOLDER
        read -p "Enter the DESTINATION bucket name (example: kbp-assets): " TARGET_BUCKET
        mc mirror $MINIO_BACKUP_DIR/$FOLDER/ local/$TARGET_BUCKET
        ;;
    4)
        exit 0
        ;;
    *)
        echo "Invalid selection."
        ;;
esac

echo -e "\nProcess Completed."
