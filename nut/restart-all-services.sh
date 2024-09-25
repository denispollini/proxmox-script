#!/bin/bash

set -e  # Stops the script if a command fails

echo
tput setaf 3
echo "######################################################"
echo "################### Restart all NUT Service"
echo "######################################################"
tput sgr0
echo
#Restart all NUT Service

service nut-server restart
service nut-client restart
systemctl restart nut-monitor
upsdrvctl stop
upsdrvctl start

echo
tput setaf 3
echo "######################################################"
echo "################### Script completed"
echo "######################################################"
tput sgr0
echo