#!/bin/bash
set -e

# Find OS-Release
echo
tput setaf 3
echo "######################################################"
echo "################### Find OS-Release"
echo "######################################################"
tput sgr0
echo

version=$(awk -F = '/VERSION_CODENAME/ {print $2}' /etc/os-release)


# Enable Repo No-Subscription
echo
tput setaf 3
echo "######################################################"
echo "################### Enable Repo No-Subscription"
echo "######################################################"
tput sgr0
echo

cat <<EOF > /etc/apt/sources.list
deb http://ftp.debian.org/debian $version main contrib
deb http://ftp.debian.org/debian $version-updates main contrib

# Proxmox VE pve-no-subscription repository provided by proxmox.com,
# NOT recommended for production use
deb http://download.proxmox.com/debian/pve $version pve-no-subscription

# security updates
deb http://security.debian.org/debian-security $version-security main contrib
EOF

# Disable Enterprise Repo
echo
tput setaf 3
echo "######################################################"
echo "################### Disable Enterprise Repo"
echo "######################################################"
tput sgr0
echo

find /etc/apt/sources.list.d/ -name "*.list") | sed -i 's/^/#/'

# Update Repo and Upgrade system
echo
tput setaf 3
echo "######################################################"
echo "################### Update Repo and Upgrade system"
echo "######################################################"
tput sgr0
echo

apt update && apt dist-upgrade -y

# Script Completed
echo
tput setaf 3
echo "######################################################"
echo "################### Script Completed"
echo "######################################################"
tput sgr0
echo



