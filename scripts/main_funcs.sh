#!/bin/bash
source config.sh

log_action() {
    log_file="$PLAYBOOKS/action_log"
    current_time=$(date '+%Y-%m-%d %H:%M:%S')
    user=$(whoami)
    action=$1

    echo "$current_time | User: $user | Action: $action" >> "$log_file"
}

run_dynamic_inventory() {
    local script_path="$INVENTORIES/dynamic/dynamic_inventory.sh"

    # Check if the script exists
    if [ ! -f "$script_path" ]; then
        echo "Error: $script_path not found!"
        exit 1
    fi

    # Check if the script is executable
    if [ ! -x "$script_path" ]; then
        echo "Error: $script_path is not executable. Making it executable now."
        chmod +x "$script_path"
    fi

    # Execute the script
    echo "Executing Dynamic Inventory Script..."
    bash "$script_path"

    # Check the exit status of the script
    if [ $? -eq 0 ]; then
        echo "Script executed successfully. Dynamic Inventory Done !!!"
    else
        echo "Error: Script execution failed."
        exit 1
    fi
}
