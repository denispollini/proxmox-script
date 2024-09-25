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
service nut-client restart
systemctl restart nut-monitor

echo
tput setaf 3
echo "######################################################"
echo "################### Script completed"
echo "######################################################"
tput sgr0
echo