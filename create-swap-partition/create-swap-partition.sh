#!/bin/bash
set -e

# Function to select the disk
echo
tput setaf 3
echo "######################################################"
echo "################### Function to select the disk"
echo "######################################################"
tput sgr0
echo

select_disk() {
    echo "Available disks:"
    lsblk -nd --output NAME,SIZE
    echo
    read -p "Enter the name of the disk to create the partition on (e.g., sda, sdb): " disk
    if [ ! -b "/dev/$disk" ]; then
        echo "The disk /dev/$disk does not exist!"
        exit 1
    fi
}

# Function to create a swap partition with fdisk
echo
tput setaf 3
echo "######################################################"
echo "################### Function to create a swap partition with fdisk"
echo "######################################################"
tput sgr0
echo

create_swap_partition() {
    echo "Creating the swap partition on /dev/$disk"
    (
        echo n      # Create a new partition
        echo p      # Primary partition type
        echo        # Partition number (default)
        echo        # First sector (default)
        echo        # Last sector (leave blank to use all available space)
        echo t      # Change the partition type
        echo        # Select the newly created partition
        echo 82     # Type 82 = Linux swap
        echo w      # Write changes to disk
    ) | fdisk /dev/$disk
}

# Function to configure the swap partition
echo
tput setaf 3
echo "######################################################"
echo "################### Function to configure the swap partition"
echo "######################################################"
tput sgr0
echo

configure_swap() {
    # Find the most recently created partition (usually the latest)
    partition="/dev/${disk}$(lsblk -nr -o NAME | grep "^${disk}" | tail -n 1)"
    
    if [ ! -b "$partition" ]; then
        echo "The partition $partition does not exist!"
        exit 1
    fi

# Create the swap filesystem on the new partition
echo
tput setaf 3
echo "######################################################"
echo "################### Create the swap filesystem on the new partition"
echo "######################################################"
tput sgr0
echo

    mkswap "$partition"

# Activate the swap partition
echo
tput setaf 3
echo "######################################################"
echo "################### Activate the swap partition"
echo "######################################################"
tput sgr0
echo
    swapon "$partition"

# Get the UUID of the swap partition
echo
tput setaf 3
echo "######################################################"
echo "################### Get the UUID of the swap partition"
echo "######################################################"
tput sgr0
echo

    uuid=$(blkid -s UUID -o value "$partition")

    if [ -z "$uuid" ]; then
        echo "Error: Unable to obtain the UUID of partition $partition."
        exit 1
    fi

# Add the swap partition to /etc/fstab
echo
tput setaf 3
echo "######################################################"
echo "################### Add the swap partition to /etc/fstab"
echo "######################################################"
tput sgr0
echo

    echo "# Mount Swap $partition" >> /etc/fstab
    echo "UUID=$uuid none swap defaults 0 0" >> /etc/fstab

    echo "Swap partition created and added to /etc/fstab successfully!"
}

# Function to ask the user if they want to create another partition
echo
tput setaf 3
echo "######################################################"
echo "################### Function to ask the user if they want to create another partition"
echo "######################################################"
tput sgr0
echo

ask_another_partition() {
    while true; do
        read -p "Do you want to create another partition? (y/n): " answer
        case $answer in
            [Yy]* ) return 0;;  # If yes, return true (continue the script)
            [Nn]* ) exit 0;;     # If no, exit the script
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Main loop to repeat the process if the user wants to create another partition
echo
tput setaf 3
echo "######################################################"
echo "################### Main loop to repeat the process if the user wants to create another partition"
echo "######################################################"
tput sgr0
echo

while true; do
    select_disk
    create_swap_partition
    configure_swap
    ask_another_partition  # Ask if the user wants to repeat
done