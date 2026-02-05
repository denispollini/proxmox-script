#!/bin/bash
set -e

# Create script
echo
tput setaf 3
echo "######################################################"
echo "################### Create script"
echo "######################################################"
tput sgr0
echo

cat <<EOF > /usr/local/bin/check-storage-space.sh
#!/bin/bash
THRESHOLD=80
EMAIL=$(cat /etc/pve/user.cfg | awk -F ':' '{print $7}')
HOSTNAME=$(hostname)
/usr/sbin/pvesm status | grep "active" | tr -d '%' | awk -v limit="$THRESHOLD" '$7 >= limit {print $1, $2, $7}' | while read -r NAME TYPE USAGE; do

    SUBJECT="Storage Alert: '$NAME' ($TYPE) at $USAGE% on $HOSTNAME"
    BODY="WARNING: Storage '$NAME' (Type: $TYPE) on server $HOSTNAME has reached $USAGE% capacity.

Details:
Storage Name: $NAME
Storage Type: $TYPE
Current Usage: $USAGE%
Threshold: $THRESHOLD%

Recommended action: Free up space, delete old snapshots/backups, or add capacity soon."

    echo "$BODY" | mail -s "$SUBJECT" "$EMAIL"
done
EOF

chmod +x /usr/local/bin/check-storage-space.sh

# Create Cronjob
echo
tput setaf 3
echo "######################################################"
echo "################### Create Cronjob"
echo "######################################################"
tput sgr0
echo

COMMENT="#Proxmox storage capacity check"
JOB="0 * * * * /usr/local/bin/check-storage-space.sh"

(crontab -l 2>/dev/null | grep -vF "$JOB" | grep -vF "$COMMENT"; echo "$COMMENT"; echo "$JOB") | crontab -


# Script Completed
echo
tput setaf 3
echo "######################################################"
echo "################### Script Completed"
echo "######################################################"
tput sgr0
echo



