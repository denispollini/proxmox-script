#!/bin/bash

echo
tput setaf 3
echo "######################################################"
echo "################### I update the package database and install Nut Server and Nut Client"
echo "######################################################"
tput sgr0
echo
# I update the package database and install Nut Server and Nut Client
set -e
apt update
apt install nut nut-client nut-server -y

echo
tput setaf 3
echo "######################################################"
echo "################### Make a backup of the configuration files before changes"
echo "######################################################"
tput sgr0
echo
# Make a backup of the configuration files before changes
cp /etc/nut/ups.conf /etc/nut/ups.conf.bak
cp /etc/nut/upsmon.conf /etc/nut/upsmon.conf.bak
cp /etc/nut/upsd.users /etc/nut/upsd.users.bak
cp /etc/nut/nut.conf /etc/nut/nut.conf.bak
cp /etc/nut/upssched.conf /etc/nut/upssched.conf.bak
cp /etc/nut/upsd.conf /etc/nut/upsd.conf.bak


echo -e "pollinterval = 1 \nmaxretry = 3 \n" > /etc/nut/ups.conf

echo
tput setaf 3
echo "######################################################"
echo "################### Redirect the output of nut-scanner -U to the /etc/nut/ups.conf file"
echo "######################################################"
tput sgr0
echo
# Redirect the output of "nut-scanner -U" to the /etc/nut/ups.conf file
# Path to the configuration file
UPS_CONF_FILE="/etc/nut/ups.conf"

echo
tput setaf 3
echo "######################################################"
echo "################### Run the nut-scanner command and capture the output"
echo "######################################################"
tput sgr0
echo
# Run the nut-scanner command and capture the output
nut_output=$(nut-scanner -U)

echo
tput setaf 3
echo "######################################################"
echo "################### Extract only the part starting with [nutdev1] and up to the end"
echo "######################################################"
tput sgr0
echo
# Extract only the part starting with [nutdev1] and up to the end
relevant_output=$(echo "$nut_output" | awk '/^\[nutdev1\]/ {found=1} found')

echo
tput setaf 3
echo "######################################################"
echo "################### Verify that the output contains the [nutdev1] section"
echo "######################################################"
tput sgr0
echo
# Verify that the output contains the [nutdev1] section
if [ -z "$relevant_output" ]; then
    echo "error: section [nutdev1] not found in output."
    exit 1
fi

echo
tput setaf 3
echo "######################################################"
echo "################### Write the relevant output to the ups.conf file"
echo "######################################################"
tput sgr0
echo
# Write the relevant output to the ups.conf file
echo "$relevant_output" >> $UPS_CONF_FILE
echo "Updated UPS configuration in file $UPS_CONF_FILE"

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
echo "################### Copy notifycmd.sh file"
echo "######################################################"
tput sgr0
echo
# Copy notifycmd.sh file
cp ./notifycmd.sh /etc/nut/notifycmd.sh

echo
tput setaf 3
echo "######################################################"
echo "################### Change group and permission for file notifycmd.sh"
echo "######################################################"
tput sgr0
echo
# Change group and permission for file notifycmd.sh
chown :nut /etc/nut/notifycmd.sh
chmod 774 /etc/nut/notifycmd.sh

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
sed -i "s/^MONITOR .*@.* 1 admin secret master$/MONITOR ${NUT_DEVICE_NAME}@${NUT_SERVER_IP} 1 admin secret master/" $UPSMON_CONF_FILE

echo "The upsmon.conf file has been successfully updated."


echo -e "LISTEN 0.0.0.0 3493" > /etc/nut/upsd.conf
echo -e "MODE=netserver" > /etc/nut/nut.conf
cp ./upsd.users /etc/nut/upsd.users

echo
tput setaf 3
echo "######################################################"
echo "################### Restart all services related"
echo "######################################################"
tput sgr0
echo
# Restart all services related.
service nut-server restart
service nut-client restart
systemctl restart nut-monitor
upsdrvctl stop
upsdrvctl start

echo
tput setaf 3
echo "######################################################"
echo "################### NUT CGI Server"
echo "######################################################"
tput sgr0
echo
#NUT CGI Server
apt install apache2 nut-cgi -y
cp /etc/nut/hosts.conf /etc/nut/hosts.conf.bak

echo
tput setaf 3
echo "######################################################"
echo "################### Path to the configuration file hosts.conf"
echo "######################################################"
tput sgr0
echo
# Path to the configuration file hosts.conf
UPSMON_CONF_FILE="/etc/nut/hosts.conf"

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
echo "################### Ask the user to enter a description of the UPS"
echo "######################################################"
tput sgr0
echo
# Ask the user to enter a description of the UPS
echo "Enter a description for the UPS (e.g. Tripp Lite 1500VA SmartUPS - Rack):"
read NUT_DESCRIPTION

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
echo "################### Replace the device name and IP address part and add description"
echo "######################################################"
tput sgr0
echo
# Replace the device name and IP address part and add description
echo -e "MONITOR ${NUT_DEVICE_NAME}@${NUT_SERVER_IP} \"$NUT_DESCRIPTION\"" > $UPSMON_CONF_FILE

echo "The upsmon.conf file has been successfully updated."

a2enmod cgi
systemctl restart apache2
cp /etc/nut/upsset.conf /etc/nut/upsset.conf.bak
echo -e "I_HAVE_SECURED_MY_CGI_DIRECTORY" > /etc/nut/upsset.conf

echo
tput setaf 3
echo "######################################################"
echo "################### Scheduling on the remote system"
echo "######################################################"
tput sgr0
echo
#Scheduling on the remote system
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
