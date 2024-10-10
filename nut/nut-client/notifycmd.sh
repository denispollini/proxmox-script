#!/bin/bash
set -e

# Email
EMAIL_RECIPIENT=$(grep '^user:root@pam' /etc/pve/user.cfg | awk -F':' '{print $7}')

# Define the message to send based on argument containing relevant string
if [[ "$1" == *"on battery"* ]]; then
    SUBJECT="UPS on Battery"
    BODY="The UPS is running on battery."
elif [[ "$1" == *"on line power"* ]]; then
    SUBJECT="UPS Power Restored"
    BODY="The UPS is back on power."
else
    exit 0
fi

# Send the email
echo "$BODY" | mail -s "$SUBJECT" $EMAIL_RECIPIENT
