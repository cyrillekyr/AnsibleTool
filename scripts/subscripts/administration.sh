#!/bin/bash

source config.sh
source main_funcs.sh 



# Display welcome message

display_administration_menu()
{

    clear
        echo """
         ___________ _   _____   _  _____________  __   ____
        / __/ __/ _ \ | / / _ | / |/ / __/  _/ _ )/ /  / __/
       _\ \/ _// , _/ |/ / __ |/    /\ \_/ // _  / /__/ _/  
      /___/___/_/|_||___/_/ |_/_/|_/___/___/____/____/___/                                                      
                                                                                   
    ╔═╗┌┬┐┌┬┐┬┌┐┌┬┌─┐┌┬┐┬─┐┌─┐┌┬┐┬┌─┐┌┐┌  ╔═╗┌─┐┌┐┌┌─┐┬  
    ╠═╣ ││││││││││└─┐ │ ├┬┘├─┤ │ ││ ││││  ╠═╝├─┤│││├┤ │  
    ╩ ╩─┴┘┴ ┴┴┘└┘┴└─┘ ┴ ┴└─┴ ┴ ┴ ┴└─┘┘└┘  ╩  ┴ ┴┘└┘└─┘┴─┘                                                              
  """                                                                                                  

    echo "Please select an administrative task:"
    echo "1. Add/Configure a node"
    echo "2. Add/Delete groups vars"
    echo "3. Server Rollback"
    echo "5. View logs"
    echo "6. Vault Configuration"
    echo "0. Return to main menu"
}

# Function to view logs
node_configuration() {
    python3 subscripts/node_configuration.py
}

# Function to clear logs
group_management() {
    python3 subscripts/group_management.py
}

# Function to perform system update
system_update() {
    log_action "Initiated system update"
    echo "Updating the system..."
    sudo apt update && sudo apt upgrade -y
    echo "System update completed."
}

# Function to backup the system
backup_system() {
    log_action "Initiated system backup"
    echo "Backing up the system..."
    sudo tar -czvf /path/to/backup/backup.tar.gz /important/system/files
    echo "System backup completed."
}

# Function to restore the system
restore_system() {
    log_action "Initiated system restore"
    echo "Restoring the system from backup..."
    sudo tar -xzvf /path/to/backup/backup.tar.gz -C /
    echo "System restore completed."
}

# Function to execute the selected administrative task
execute_administration_task() {
    echo ""
    read -r admin_choice

    case $admin_choice in
    1) node_configuration ;;
    2) group_management ;;
    3) system_update ;;
    4) backup_system ;;
    5) restore_system ;;
    0)
        log_action "Returned to main menu"
        exit 0
        ;;
    *)
        log_action "Invalid administrative option selected"
        echo "Invalid option"
        ;;
    esac
}

# Main function for administration script
administration_main() {
    while true; do
        display_administration_menu
        execute_administration_task
        echo ""
        echo -n "Press enter to return to the administration menu..."
        read -r input
    done
}

# Execute the administration script
administration_main 