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
restore_dir="/tmp/restore"  # Temporary directory for restoration
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")  # Current date and time for logging

# Ask the user for the Nextcloud WebDAV URL
read -p "Enter the Nextcloud WebDAV URL (where the backup is stored): " nextcloud_url

# Ask the user for their username
read -p "Enter your Nextcloud username: " username

# Ask the user for the password
read -s -p "Enter your Nextcloud password: " password
echo  # To return after the password

# Test access to Nextcloud via WebDAV
echo "Checking your Nextcloud login credentials..."
login_response=$(curl -s -o /dev/null -w "%{http_code}" -u "$username:$password" "$nextcloud_url")

# Check if you logged in successfully
if [ "$login_response" -eq 200 ]; then
  echo "Successful login to Nextcloud!"
else
  echo "Nextcloud login error. HTTP response code: $login_response"
  exit 1  # Stop the script on login error
fi

echo
tput setaf 3
echo "######################################################"
echo "################### Create temporary restore directory"
echo "######################################################"
tput sgr0
echo

# Create a temporary directory for restoration
mkdir -p "$restore_dir"

# Ask the user for the name of the backup file to download
read -p "Enter the name of the backup file to download (e.g., proxmox_backup_YYYY-MM-DD_HH-MM-SS.tar.gz): " backup_file_name

echo
tput setaf 3
echo "######################################################"
echo "################### Downloading the backup file"
echo "######################################################"
tput sgr0
echo

# Download the backup file from Nextcloud
curl -s -u "$username:$password" -o "$restore_dir/$backup_file_name" "$nextcloud_url/$backup_file_name"  # Adjust the URL as needed

echo
tput setaf 3
echo "######################################################"
echo "################### Check if the backup was downloaded successfully"
echo "######################################################"
tput sgr0
echo

# Check if the download was successful
if [ -f "$restore_dir/$backup_file_name" ]; then
  echo "Backup file downloaded successfully: $restore_dir/$backup_file_name"

  echo
  tput setaf 3
  echo "######################################################"
  echo "################### Restoring the /etc folder"
  echo "######################################################"
  tput sgr0
  echo

  # Restore the /etc folder
  sudo tar -xzvf "$restore_dir/$backup_file_name" -C /etc

  echo
  tput setaf 3
  echo "######################################################"
  echo "################### Restore completed successfully"
  echo "######################################################"
  tput sgr0
  echo

else
  echo "Error downloading backup file from Nextcloud."
  exit 1  # Stop the script on download error
fi

# Clean up the temporary restore directory
rm -rf "$restore_dir"

echo
tput setaf 3
echo "######################################################"
echo "################### Script Completed"
echo "######################################################"
tput sgr0
echo
