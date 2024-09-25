#!/bin/bash
set -e

echo
tput setaf 3
echo "######################################################"
echo "################### Update Repo and install Fail2Ban"
echo "######################################################"
tput sgr0
echo
#Update Repo and install Fail2Ban
apt update
apt install fail2ban -y

echo
tput setaf 3
echo "######################################################"
echo "################### Setup Base Config"
echo "######################################################"
tput sgr0
echo
#Setup Base Config
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

echo
tput setaf 3
echo "######################################################"
echo "################### Base Config"
echo "######################################################"
tput sgr0
echo
#Base Config
cat <<EOF >> /etc/fail2ban/jail.local
[proxmox]
enabled = true
port = https,http,8006
filter = proxmox
backend = systemd
maxretry = 3
findtime = 2d
bantime = 1h
EOF

echo
tput setaf 3
echo "######################################################"
echo "################### Filter Config"
echo "######################################################"
tput sgr0
echo
#Filter Config
cat <<EOF >> /etc/fail2ban/filter.d/proxmox.conf
[Definition]
failregex = pvedaemon\[.*authentication failure; rhost=<HOST> user=.* msg=.*
ignoreregex =
journalmatch = _SYSTEMD_UNIT=pvedaemon.service
EOF

echo
tput setaf 3
echo "######################################################"
echo "################### Restart Service to Enable Config"
echo "######################################################"
tput sgr0
echo
#Restart Service to Enable Config
systemctl restart fail2ban

echo
tput setaf 3
echo "######################################################"
echo "################### Script completed"
echo "######################################################"
tput sgr0
echo

