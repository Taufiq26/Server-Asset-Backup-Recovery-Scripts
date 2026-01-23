# 🚀 Automated Server Backup & Recovery Plan

This repository contains a professional-grade suite of shell scripts for automated backups and disaster recovery (DR) on **Debian 11**. It is optimized for efficiency on servers with limited resources (2GB RAM / 60GB Storage).

---

## 📋 Features
* **Modular Architecture**: Separate logic for PostgreSQL, MongoDB, and MinIO Assets.
* **Retention Management**: 
    * **Databases**: Keeps the latest **7 daily backups**.
    * **Assets**: Keeps the latest **2 full versions**.
* **Interactive Recovery Manager**: A guided script to restore data to production or staging environments.
* **Cron Integration**: Designed for low-traffic period execution to minimize RAM impact.
* **Centralized Logging**: All backup outputs are piped to a single log file for easy auditing.

---

## 🛠️ Successfully implemented in this environment specifications
* **OS**: Debian 11 (Bullseye)
* **PostgreSQL**: v13.21
* **MongoDB**: v100.12.2 (Database Tools)
* **Object Storage**: MinIO (Native) + `mc` client
* **Hardware**: 2 Core CPU / 2GB RAM / 60GB Storage

---

## 📂 Directory Structure
Ensure these directories exist before deploying the scripts:

```bash
/root/scripts-backup/      # Repository scripts location
/var/backups/
├── pg_data/               # PostgreSQL .sql dumps
├── mongo_data/            # MongoDB .gz archives
└── minio_assets/          # Local MinIO mirrors
```

## ⚙️ Setup & Configuration
1. PostgreSQL Authentication (.pgpass)
To enable non-interactive backups, create a .pgpass file in your home directory:

```Plaintext
# File: /root/.pgpass
# Format: hostname:port:database:username:password
localhost:5432:db_name:username:your_password
```

Required Security Step: chmod 0600 /root/.pgpass

2. MinIO Client (mc) Setup
Register your local MinIO instance with the mc client:

```bash
mc alias set local [http://127.0.0.1:9000](http://127.0.0.1:9000) YOUR_ACCESS_KEY YOUR_SECRET_KEY
```

---

## 🚀 Usage
Manual Execution
Run specific scripts as needed from the script directory:

```bash
~/scripts-backup/backup_pg.sh      # Backup PostgreSQL
~/scripts-backup/backup_mongo.sh   # Backup MongoDB
~/scripts-backup/backup_assets.sh  # Backup MinIO Assets
```

Automated Scheduling (Cron)
Add the following to your crontab -e to automate backups during low-traffic hours:

```bash
# 02:00 AM - PostgreSQL Backup
0 2 * * * /bin/bash /root/scripts-backup/backup_pg.sh >> /root/scripts-backup/backup_log.log 2>&1

# 02:15 AM - MongoDB Backup
15 2 * * * /bin/bash /root/scripts-backup/backup_mongo.sh >> /root/scripts-backup/backup_log.log 2>&1

# 02:30 AM - MinIO Assets Backup
30 2 * * * /bin/bash /root/scripts-backup/backup_assets.sh >> /root/scripts-backup/backup_log.log 2>&1
```

---

## 🚑 Data Recovery
Interactive Restore Manager
Run the interactive manager for a safe, guided recovery process:

```bash
~/scripts-backup/restore_data.sh
```

Manual Recovery Commands
- PostgreSQL: psql -U username -d target_db < /var/backups/pg_data/your_file.sql
- MongoDB: mongorestore --db=target_db --username=admin --password=xxx --authenticationDatabase=admin --archive=/var/backups/mongo_data/your_file.gz --gzip
- MinIO Assets: mc mirror /var/backups/minio_assets/your_folder/ local/target-bucket
