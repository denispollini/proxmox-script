#!/bin/bash
set -e

# File di log per debug
LOGFILE="/var/log/ups-email-notifier.log"
echo "$(date) - Script invoked with argument: $1" >> $LOGFILE

# Email
EMAIL_RECIPIENT=$(grep '^user:root@pam' /etc/pve/user.cfg | awk -F':' '{print $7}')
echo "$(date) - Email recipient: $EMAIL_RECIPIENT" >> $LOGFILE

# Define the message to send based on argument containing relevant string
if [[ "$1" == *"on battery"* ]]; then
    SUBJECT="UPS on Battery"
    BODY="The UPS is running on battery."
    echo "$(date) - UPS is running on battery" >> $LOGFILE
elif [[ "$1" == *"on line power"* ]]; then
    SUBJECT="UPS Power Restored"
    BODY="The UPS is back on power."
    echo "$(date) - UPS is back on power" >> $LOGFILE
else
    echo "$(date) - Invalid state or argument: $1" >> $LOGFILE
    exit 0
fi

# Send the email
echo "$BODY" | mail -s "$SUBJECT" $EMAIL_RECIPIENT
echo "$(date) - Email sent" >> $LOGFILE