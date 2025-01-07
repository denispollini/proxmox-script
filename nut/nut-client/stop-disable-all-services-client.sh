#!/bin/bash

set -e  # Stops the script if a command fails

echo
tput setaf 3
echo "######################################################"
echo "################### Stop all NUT Service"
echo "######################################################"
tput sgr0
echo
#Restart all NUT Service
service nut-client stop
systemctl stop nut-monitor

echo
tput setaf 3
echo "######################################################"
echo "################### Disable all NUT Service"
echo "######################################################"
tput sgr0
echo
#Restart all NUT Service
systemclt disable nut-client
systemctl disable nut-monitor

echo
tput setaf 3
echo "######################################################"
echo "################### Script completed"
echo "######################################################"
tput sgr0
echo