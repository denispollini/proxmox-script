#!/bin/bash
set -e

#Email
EMAIL_RECIPIENT=$(grep '^user:root@pam' /etc/pve/user.cfg | awk -F':' '{print $7}')

# Define the message to send
if [ "$1" = "online" ]; then
    SUBJECT="UPS Power Restored"
    BODY="The UPS is back on power."
elif [ "$1" = "onbatt" ]; then
    SUBJECT="UPS on Battery"
    BODY="The UPS is running on battery."
else
    exit 0
fi

# Send the email
echo "$BODY" | mail -s "$SUBJECT" $EMAIL_RECIPIENT
