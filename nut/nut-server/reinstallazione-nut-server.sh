#!/bin/bash
# I update the package database and install Nut Server and Nut Client
set -e
apt update
apt install nut nut-client nut-server -y

# Make a backup of the configuration files before changes
cp /etc/nut/ups.conf /etc/nut/ups.conf.bak
cp /etc/nut/upsmon.conf /etc/nut/upsmon.conf.bak
cp /etc/nut/upsd.users /etc/nut/upsd.users.bak
cp /etc/nut/nut.conf /etc/nut/nut.conf.bak
cp /etc/nut/upssched.conf /etc/nut/upssched.conf.bak
cp /etc/nut/upsd.conf /etc/nut/upsd.conf.bak


echo -e "pollinterval = 1 \nmaxretry = 3 \n" > /etc/nut/ups.conf


# Redirect the output of "nut-scanner -U" to the /etc/nut/ups.conf file
# Path to the configuration file
UPS_CONF_FILE="/etc/nut/ups.conf"

# Run the nut-scanner command and capture the output
nut_output=$(nut-scanner -U)
# Extract only the part starting with [nutdev1] and up to the end
relevant_output=$(echo "$nut_output" | awk '/^\[nutdev1\]/ {found=1} found')
# Verify that the output contains the [nutdev1] section
if [ -z "$relevant_output" ]; then
    echo "error: section [nutdev1] not found in output."
    exit 1
fi

# Write the relevant output to the ups.conf file
echo "$relevant_output" >> $UPS_CONF_FILE
echo "Updated UPS configuration in file $UPS_CONF_FILE"

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
sed -i "s/^MONITOR .*@.* 1 admin secret master$/MONITOR ${NUT_DEVICE_NAME}@${NUT_SERVER_IP} 1 admin secret master/" $UPSMON_CONF_FILE

echo "The upsmon.conf file has been successfully updated."


echo -e "LISTEN 0.0.0.0 3493" > /etc/nut/upsd.conf
echo -e "MODE=netserver" > /etc/nut/nut.conf
cp ./upsd.users /etc/nut/upsd.users


# Restart all services related.
service nut-server restart
service nut-client restart
systemctl restart nut-monitor
upsdrvctl stop
upsdrvctl start

#NUT CGI Server
apt install apache2 nut-cgi -y
cp /etc/nut/hosts.conf /etc/nut/hosts.conf.bak

# Path to the configuration file
UPSMON_CONF_FILE="/etc/nut/hosts.conf"

# Prompt the user to enter the NUT device name
echo "Enter the NUT device name (e.g. apc-modem):"
read NUT_DEVICE_NAME

# Ask the user to enter the IP address of the NUT server
echo "Enter the IP address of the NUT server (e.g. 192.168.1.100):"
read NUT_SERVER_IP

# Ask the user to enter a description of the UPS
echo "Enter a description for the UPS (e.g. Tripp Lite 1500VA SmartUPS - Rack):"
read NUT_DESCRIPTION

# Verify that the user entered both the device name and IP address
if [ -z "$NUT_DEVICE_NAME" ] || [ -z "$NUT_SERVER_IP" ]; then
    echo "Device name or IP address not provided. Exit."
    exit 1
fi

# Replace the device name and IP address part and add description
echo -e "MONITOR ${NUT_DEVICE_NAME}@${NUT_SERVER_IP} \"$NUT_DESCRIPTION\"" > $UPSMON_CONF_FILE

echo "The upsmon.conf file has been successfully updated."

a2enmod cgi
systemctl restart apache2
cp /etc/nut/upsset.conf /etc/nut/upsset.conf.bak
echo -e "I_HAVE_SECURED_MY_CGI_DIRECTORY" > /etc/nut/upsset.conf

#Scheduling on the remote system
cp ./upssched.conf /etc/nut/upssched.conf
cp ./upssched-cmd /etc/nut/upssched-cmd
chmod +x /etc/nut/upssched-cmd
systemctl restart nut-client

echo "Script Completed."
