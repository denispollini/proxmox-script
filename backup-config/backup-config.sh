#!/bin/bash

echo
tput setaf 3
echo "######################################################"
echo "################### Configuration"
echo "######################################################"
tput sgr0
echo
# Configuration
backup_dir="/backup/proxmox"  # Backup destination folder
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")  # Current date and time for the file name
backup_file="$backup_dir/proxmox_backup_$timestamp.tar.gz"  # Backup file name

echo
tput setaf 3
echo "######################################################"
echo "################### Check if the backup directory exists, otherwise create it"
echo "######################################################"
tput sgr0
echo
# Check if the backup directory exists, otherwise create it
if [ ! -d "$backup_dir" ]; then
  mkdir -p "$backup_dir"
fi

echo
tput setaf 3
echo "######################################################"
echo "################### Back up the /etc folder"
echo "######################################################"
tput sgr0
echo
# Back up the /etc folder
tar -czvf "$backup_file" /etc

echo
tput setaf 3
echo "######################################################"
echo "################### Check if the backup was created successfully"
echo "######################################################"
tput sgr0
echo
# Check if the backup was created successfully
if [ $? -eq 0 ]; then
  echo "Backup completed successfully: $backup_file"
else
  echo "Error during backup"
fi

echo
tput setaf 3
echo "######################################################"
echo "################### Script Completed"
echo "######################################################"
tput sgr0
echo