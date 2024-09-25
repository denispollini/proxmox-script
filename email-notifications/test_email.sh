#!/bin/bash
set -e

echo
tput setaf 3
echo "######################################################"
echo "################### Insert the email address you want to use for send email test"
echo "######################################################"
tput sgr0
echo

read email_address

echo "This is a test message sent from postfix on my Proxmox Server" | mail -s "Test Email from Proxmox" $email_address

echo
tput setaf 3
echo "######################################################"
echo "################### Email sent"
echo "######################################################"
tput sgr0
echo