#!/bin/bash
set -e

#Update Repo and install Fail2Ban
apt update
apt install fail2ban

#Setup Base Config
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

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

#Filter Config
cat <<EOF >> /etc/fail2ban/filter.d/proxmox.conf
[Definition]
failregex = pvedaemon\[.*authentication failure; rhost=<HOST> user=.* msg=.*
ignoreregex =
journalmatch = _SYSTEMD_UNIT=pvedaemon.service
EOF

#Restart Service to Enable Config
systemctl restart fail2ban

echo "Script Completed."

