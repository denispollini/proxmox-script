#!/bin/bash
set -e

echo
tput setaf 3
echo "######################################################"
echo "################### Configuration"
echo "######################################################"
tput sgr0
echo

# Configuration
backup_dir="/backup/proxmox"  # Backup source folder
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")  # Current date and time for logging

# Ask the user for the name of the backup file to restore
read -p "Enter the name of the backup file to restore (e.g., proxmox_backup_YYYY-MM-DD_HH-MM-SS.tar.gz): " backup_file_name
restore_file="$backup_dir/$backup_file_name"  # Full path to the backup file

echo
tput setaf 3
echo "######################################################"
echo "################### Check if the backup file exists"
echo "######################################################"
tput sgr0
echo

# Check if the backup file exists
if [ -f "$restore_file" ]; then
  echo "Backup file found: $restore_file"
else
  echo "Backup file does not exist: $restore_file"
  exit 1  # Stop the script if the file does not exist
fi

echo
tput setaf 3
echo "######################################################"
echo "################### Restoring the /etc folder"
echo "######################################################"
tput sgr0
echo

# Restore the /etc folder
sudo tar -xzvf "$restore_file" -C /etc

echo
tput setaf 3
echo "######################################################"
echo "################### Restore completed successfully"
echo "######################################################"
tput sgr0
echo

echo
tput setaf 3
echo "######################################################"
echo "################### Script Completed"
echo "######################################################"
tput sgr0
echo
