#!/bin/bash

# Configuration
backup_dir="/backup/proxmox"  # Backup destination folder
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")  # Current date and time for the file name
backup_file="$backup_dir/proxmox_backup_$timestamp.tar.gz"  # Backup file name

# Check if the backup directory exists, otherwise create it
if [ ! -d "$backup_dir" ]; then
  mkdir -p "$backup_dir"
fi

# Back up the /etc folder
tar -czvf "$backup_file" /etc

# Check if the backup was created successfully
if [ $? -eq 0 ]; then
  echo "Backup completed successfully: $backup_file"
else
  echo "Error during backup"
fi
