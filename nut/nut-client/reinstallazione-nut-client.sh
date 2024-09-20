#!/bin/bash
# I update the package database and install Nut Server and Nut Client
set -e
apt update
apt install nut nut-client -y

# Make a backup of the configuration files before changes
cp /etc/nut/upsmon.conf /etc/nut/upsmon.conf.bak
cp /etc/nut/nut.conf /etc/nut/nut.conf.bak
cp /etc/nut/upssched.conf /etc/nut/upssched.conf.bak


# Copy upsmon.conf file
cp ./upsmon.conf /etc/nut/upsmon.conf


# Path to the configuration file
UPSMON_CONF_FILE="/etc/nut/upsmon.conf"

# Prompt the user to enter the NUT device name
echo "Enter the NUT device name (e.g. apc-modem):"
read NUT_DEVICE_NAME

# Ask the user to enter the IP address of the NUT server
echo "Enter the IP address of the NUT server (e.g. 192.168.1.100):"
read NUT_SERVER_IP

# Verify that the user entered both the device name and IP address
if [ -z "$NUT_DEVICE_NAME" ] || [ -z "$NUT_SERVER_IP" ]; then
    echo "Device name or IP address not provided. Exit."
    exit 1
fi

# Replace only the device name and IP address part
sed -i "s/^MONITOR .*@.* 1 admin secret slave$/MONITOR ${NUT_DEVICE_NAME}@${NUT_SERVER_IP} 1 admin secret slave/" $UPSMON_CONF_FILE

echo "The upsmon.conf file has been successfully updated."

echo -e "MODE=netclient" > /etc/nut/nut.conf

# Restarting nut-client service
systemctl restart nut-client

# Scheduling on the remote system
cp ./upssched.conf /etc/nut/upssched.conf
cp ./upssched-cmd /etc/nut/upssched-cmd
chmod +x /etc/nut/upssched-cmd
systemctl restart nut-client

echo "Script Completed."
