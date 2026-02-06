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


---


# ☁️ Rclone Setup & Google Drive Integration

Documentation for installing Rclone and connecting it to Google Drive on a headless Debian 11 server.

---

## 🛠️ 1. Installation

Since the default repository might be outdated or unreachable, use the official installation script to get the latest version (v1.73.0+):

```bash
sudo -v ; curl [https://rclone.org/install.sh](https://rclone.org/install.sh) | sudo bash
```

Verify installation

```bash
rclone version
```

## ⚙️ 2. Google Drive Configuration (Headless Mode)
Because the server does not have a GUI/Browser, we use the Remote Authentication method.
1. Run the config wizard:
```bash
rclone config
```
2. Select n for New Remote.
3. Name it: gdrive.
4. Storage Type: Select drive (Google Drive).
5. Client ID/Secret: Leave blank (Press Enter).
6. Scope: Select 1 (Full access).
7. Advanced Config: Select n.
8. Use auto-config?: Select n (Required for Headless/SSH).

## 🔑 3. Remote Authorization Flow
When prompted for config_token, follow these steps on your Local Machine (Laptop/PC):
1. Download Rclone for your OS (Windows/Mac/Linux).
2. Open your local terminal/command prompt.
3. Run the command provided by the server:
```bash
rclone authorize "drive" "TOKEN_STRING_FROM_SERVER"
```
4. A browser window will open. Log in to your Google Account and click Allow.
5. Copy the JSON token code {...} generated in your local terminal.
6. Paste the token back into the Server terminal and press Enter.

## 🚀 4. Usage & Integration
Basic Commands
- Create Folder: rclone mkdir gdrive:backups_project_x
- List Files: rclone ls gdrive:backups_project_x
- Check Size: rclone size gdrive:backups_project_x

Automated Sync in Scripts
To integrate cloud backup into existing scripts, use the following commands:
```bash
# Copy file to Cloud
rclone copy /path/to/backup.sql gdrive:backups_project_x/pg_data/

# Retention: Delete files older than 7 days in Cloud
rclone delete gdrive:backups_project_x/ --min-age 7d --rmdirs
```
