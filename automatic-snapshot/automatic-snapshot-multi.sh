#!/bin/bash

# --- CONFIGURATION ---
EMAIL=$(grep '^user:root@pam' /etc/pve/user.cfg | awk -F':' '{print $7}')
VMIDS="100 101 102"  # Enter VM IDs separated by a space
DAYS="3"             # Retention period in days
# ----------------------

set -e  # Exit immediately if a command exits with a non-zero status

for VMID in $VMIDS; do
    echo "--- Processing VM $VMID ---"
    
    # Snapshot name includes date/time for easy identification
    SNAPSHOT_NAME="snapshot-$(date +%Y-%m-%d_%H-%M-%S)"

    # Create snapshot with error handling
    if ! /usr/sbin/qm snapshot $VMID $SNAPSHOT_NAME; then
        echo "Error creating snapshot for VM $VMID" | mail -s "Proxmox Snapshot Error - VM $VMID" $EMAIL
        # Use 'continue' to skip to the next VM if one fails
        continue 
    fi

    # Remove snapshots older than X days
    /usr/sbin/qm listsnapshot $VMID | grep 'snapshot-' | awk '{print $2}' | while read SNAPSHOT; do
        
        # Parse date from snapshot name (converts format for the 'date' command)
        SNAPSHOT_DATE=$(echo $SNAPSHOT | sed 's/snapshot-//; s/_/ /; s/-/:/3g')
        SNAPSHOT_TIMESTAMP=$(date -d "$SNAPSHOT_DATE" +%s 2>/dev/null)

        if [ -z "$SNAPSHOT_TIMESTAMP" ]; then
            echo "Error parsing date for snapshot: $SNAPSHOT" | mail -s "Proxmox Parsing Error - VM $VMID" $EMAIL
            continue
        fi

        # Calculate the cutoff timestamp
        LIMIT_DATE=$(date -d "$DAYS days ago" +%s)

        # Compare timestamps and delete if older than the limit
        if [ "$SNAPSHOT_TIMESTAMP" -lt "$LIMIT_DATE" ]; then
            if /usr/sbin/qm delsnapshot $VMID $SNAPSHOT; then
                echo "VM $VMID: Snapshot $SNAPSHOT successfully deleted."
            else
                echo "Error deleting snapshot $SNAPSHOT on VM $VMID" | mail -s "Proxmox Deletion Error - VM $VMID" $EMAIL
            fi
        fi
    done
done

echo "Operation completed for all VMs."