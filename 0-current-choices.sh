#!/bin/bash

# Function to display the menu
show_menu() {
    echo "Choose an option:"
    echo "1) Disable Enterprise repos and enable No-Subscription repos"
    echo "2) Create SWAP partition"
    echo "3) Backup Configuration"
    echo "4) Backup Configuration and send to Nextcloud"
    echo "5) Restore Configuration"
    echo "6) Restore Configuration from Nextcloud"
    echo "7) Configure Email Notification"
    echo "8) NUT Server"
    echo "9) NUT Client"
    echo "10) Fail2Ban"
    echo "11) Automatic VM Snapshot"
    echo "99) Quit"
}

# Function to execute the command based on the user's choice
execute_choice() {
    case $1 in
        1)
            echo "Running script to disable Enterprise repos and enable No-Subscription repos..."
            ./enable-repo-no-sub/enable-repo-no-sub.sh # Replace with the actual script name
            ;;
        2)
            echo "Running script to create a SWAP partition..."
            ./create-swap-partition/create-swap-partition.sh # Replace with the actual script name
            ;;
        3)
            echo "Running script to backup configuration..."
            ./backup-config/backup-config.sh # Replace with the actual script name
            ;;
        4)
            echo "Running script to backup configuration and send to Nextcloud..."
            ./backup-config/backup-config-sendtonextcloud.sh # Replace with the actual script name
            ;;
        5)
            echo "Running script to restore configuration..."
            ./restore-config/restore-config.sh # Replace with the actual script name
            ;;
        6)
            echo "Running script to restore configuration from Nextcloud..."
            ./restore-config/restore-config-from-nextcloud.sh # Replace with the actual script name
            ;;
        7)
            echo "Running script to configure email-notifications..."
            ./email-notifications/setup-email-notifications.sh # Replace with the actual script name
            ;;
        8)
            echo "Running script to configure the NUT Server..."
            ./nut/nut-server/reinstall-nut-server.sh # Replace with the actual script name
            ;;
        9)
            echo "Running script to configure the NUT Client..."
            ./nut/nut-client/reinstall-nut-client.sh # Replace with the actual script name
            ;;
        10)
            echo "Running script to configure Fail2Ban..."
            ./fail2ban/fail2ban.sh # Replace with the actual script name
            ;;
        11)
            echo "Running script to configure automatic snapshot..."
            ./automatic-snapshot/automatic-snapshot.sh # Replace with the actual script name
            ;;
        99)
            echo "Exiting... Thank you for using the menu!"
            exit 0
            ;;
        *)
            echo "Invalid choice, please try again."
            ;;
    esac
}

# Main loop to display the menu until the user chooses to exit
while true; do
    show_menu
    read -p "Enter your choice (1-10): " choice
    execute_choice $choice
    echo
done
