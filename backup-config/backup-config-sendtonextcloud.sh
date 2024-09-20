#!/bin/bash
set -e

# Configuration
backup_dir="/backup/proxmox"  # Backup destination folder
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")  # Current date and time for the file name
backup_file="$backup_dir/proxmox_backup_$timestamp.tar.gz"  # Backup file name
nextcloud_url="https://ip_adress_of_nextcloud_server/remote.php/dav/files/XXXXXXXXXXXXXXXXXXXXXX/folder/"  # WebDAV URL of the Nextcloud folder
username="proxmox"  # Your Nextcloud username
password="proxmox"  # Your Nextcloud password

# Check if the backup directory exists, otherwise create it
if [ ! -d "$backup_dir" ]; then
  mkdir -p "$backup_dir"
fi

# Back up the /etc folder
tar -czvf "$backup_file" /etc

# Check if the backup was created successfully
if [ $? -eq 0 ]; then
  echo "Backup completed successfully: $backup_file"
  
  # Upload the backup file using curl to Nextcloud via WebDAV
  curl_response=$(curl -s -o /dev/null -w "%{http_code}" -u "$username:$password" -T "$backup_file" "$nextcloud_url")

  # Check the upload status
  if [ "$curl_response" -eq 201 ]; then
    echo "Backup file upload completed successfully to Nextcloud: $nextcloud_url"
  else
    echo "Error uploading backup file to Nextcloud. HTTP response code: $curl_response"
  fi
else
  echo "Error during backup"
fi
