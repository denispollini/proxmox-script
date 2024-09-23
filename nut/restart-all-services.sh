#!/bin/bash

set -e  # Stops the script if a command fails

#Restart all NUT Service

service nut-server restart
service nut-client restart
systemctl restart nut-monitor
upsdrvctl stop
upsdrvctl start
