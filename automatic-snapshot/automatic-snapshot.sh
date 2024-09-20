#!/bin/bash

set -e  # Stops the script if a command fails

# Extract the email address associated with the root user from Proxmox configuration
EMAIL=$(grep '^user:root@pam' /etc/pve/user.cfg | awk -F':' '{print $7}')

# Check if the email was found
if [ -z "$EMAIL" ]; then
    echo "No email found for root@pam in /etc/pve/user.cfg. Exiting."
    exit 1
fi

# VM ID
VMID="100"

# Snapshot name (may include timestamp for better identification)
SNAPSHOT_NAME="snapshot-$(date +%Y-%m-%d_%H-%M-%S)"
# Snapshot creation with error handling
if ! /usr/sbin/qm snapshot $VMID $SNAPSHOT_NAME; then
    echo "Error creating snapshot for VM $VMID" | mail -s "Proxmox Snapshot Error" $EMAIL
    exit 1
fi

# Removing snapshots older than 7 days
/usr/sbin/qm listsnapshot $VMID | grep 'snapshot-' | awk '{print $2}' | while read SNAPSHOT; do
    SNAPSHOT_DATE=$(echo $SNAPSHOT | sed 's/snapshot-//; s/_/ /; s/-/:/3g')
    SNAPSHOT_TIMESTAMP=$(date -d "$SNAPSHOT_DATE" +%s 2>/dev/null)

    if [ -z "$SNAPSHOT_TIMESTAMP" ]; then
        echo "Error parsing snapshot date: $SNAPSHOT" | mail -s "Proxmox Snapshot Parsing Error" $EMAIL
        continue
    fi

    SEVEN_DAYS_AGO=$(date -d "7 days ago" +%s)

    if [ "$SNAPSHOT_TIMESTAMP" -lt "$SEVEN_DAYS_AGO" ]; then
        if /usr/sbin/qm delsnapshot $VMID $SNAPSHOT; then
            echo "Snapshot $SNAPSHOT successfully deleted."
        else
            echo "Error deleting snapshot $SNAPSHOT" | mail -s "Proxmox Snapshot Deletion Error" $EMAIL
        fi
    fi
done