#!/bin/bash

echo
tput setaf 3
echo "######################################################"
echo "################### I update the package database and install Nut Client"
echo "######################################################"
tput sgr0
echo
# I update the package database and install Nut Server and Nut Client
set -e
apt update
apt install nut nut-client -y

echo
tput setaf 3
echo "######################################################"
echo "################### Make a backup of the configuration files before changes"
echo "######################################################"
tput sgr0
echo
# Make a backup of the configuration files before changes
cp /etc/nut/upsmon.conf /etc/nut/upsmon.conf.bak
cp /etc/nut/nut.conf /etc/nut/nut.conf.bak
cp /etc/nut/upssched.conf /etc/nut/upssched.conf.bak

echo
tput setaf 3
echo "######################################################"
echo "################### Copy upsmon.conf file"
echo "######################################################"
tput sgr0
echo
# Copy upsmon.conf file
cp ./upsmon.conf /etc/nut/upsmon.conf

echo
tput setaf 3
echo "######################################################"
echo "################### Path to the configuration file upsmon.conf"
echo "######################################################"
tput sgr0
echo
# Path to the configuration file upsmon.conf
UPSMON_CONF_FILE="/etc/nut/upsmon.conf"

echo
tput setaf 3
echo "######################################################"
echo "################### Prompt the user to enter the NUT device name"
echo "######################################################"
tput sgr0
echo
# Prompt the user to enter the NUT device name
echo "Enter the NUT device name (e.g. apc-modem):"
read NUT_DEVICE_NAME

echo
tput setaf 3
echo "######################################################"
echo "################### Ask the user to enter the IP address of the NUT server"
echo "######################################################"
tput sgr0
echo
# Ask the user to enter the IP address of the NUT server
echo "Enter the IP address of the NUT server (e.g. 192.168.1.100):"
read NUT_SERVER_IP

echo
tput setaf 3
echo "######################################################"
echo "################### Verify that the user entered both the device name and IP address"
echo "######################################################"
tput sgr0
echo
# Verify that the user entered both the device name and IP address
if [ -z "$NUT_DEVICE_NAME" ] || [ -z "$NUT_SERVER_IP" ]; then
    echo "Device name or IP address not provided. Exit."
    exit 1
fi

echo
tput setaf 3
echo "######################################################"
echo "################### Replace only the device name and IP address part"
echo "######################################################"
tput sgr0
echo
# Replace only the device name and IP address part
sed -i "s/^MONITOR .*@.* 1 admin secret slave$/MONITOR ${NUT_DEVICE_NAME}@${NUT_SERVER_IP} 1 admin secret slave/" $UPSMON_CONF_FILE

echo "The upsmon.conf file has been successfully updated."

echo -e "MODE=netclient" > /etc/nut/nut.conf

echo
tput setaf 3
echo "######################################################"
echo "################### Restarting nut-client service"
echo "######################################################"
tput sgr0
echo
# Restarting nut-client service
systemctl restart nut-client

echo
tput setaf 3
echo "######################################################"
echo "################### Scheduling on the remote system"
echo "######################################################"
tput sgr0
echo
# Scheduling on the remote system
cp ./upssched.conf /etc/nut/upssched.conf
cp ./upssched-cmd /etc/nut/upssched-cmd
chmod +x /etc/nut/upssched-cmd
systemctl restart nut-client

echo
tput setaf 3
echo "######################################################"
echo "################### Script completed"
echo "######################################################"
tput sgr0
echo
