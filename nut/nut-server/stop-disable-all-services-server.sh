#!/bin/bash

set -e  # Stops the script if a command fails

echo
tput setaf 3
echo "######################################################"
echo "################### Stop all NUT Service"
echo "######################################################"
tput sgr0
echo
#Stop all NUT Service
service nut-server stop
service nut-client stop
systemctl stop nut-monitor
upsdrvctl stop

echo
tput setaf 3
echo "######################################################"
echo "################### Stop Apache2 Service"
echo "######################################################"
tput sgr0
echo
#Restart Apache2 Service
systemctl stop apache2

echo
tput setaf 3
echo "######################################################"
echo "################### Disable all NUT Service"
echo "######################################################"
tput sgr0
echo
#Disable all NUT Service
systemctl disable nut-server
systemctl disable nut-client
systemctl disable nut-monitor

echo
tput setaf 3
echo "######################################################"
echo "################### Disable Apache2 Service"
echo "######################################################"
tput sgr0
echo
#Restart Apache2 Service
systemctl disable apache2


echo
tput setaf 3
echo "######################################################"
echo "################### Script completed"
echo "######################################################"
tput sgr0
echo