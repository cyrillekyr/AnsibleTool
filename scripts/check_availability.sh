#!/bin/bash

source main_funcs.sh

# Define the command to run the Ansible ping
ANSIBLE_CMD="ansible all -i ../inventories/all.hosts -m ping"

run_dynamic_inventory


# Run the Ansible command and capture the output
OUTPUT=$(eval "$ANSIBLE_CMD")

# Initialize arrays to store the results
SUCCESS_SERVERS=()
UNREACHABLE_SERVERS=()

# Process the output to categorize and clean up the results
while IFS= read -r line; do
    if [[ "$line" == *"SUCCESS"* ]]; then
        SERVER_NAME=$(echo "$line" | cut -d' ' -f1)
        SUCCESS_SERVERS+=("$SERVER_NAME")
    elif [[ "$line" == *"UNREACHABLE"* ]]; then
        SERVER_NAME=$(echo "$line" | cut -d' ' -f1)
        UNREACHABLE_SERVERS+=("$SERVER_NAME")
    fi
done <<< "$OUTPUT"

# Display the results grouped by status
echo "Server Availability Report:"
echo "==========================="

echo -e "\033[32mAvailable Servers:\033[0m"
for server in "${SUCCESS_SERVERS[@]}"; do
    echo -e "\033[32m$server\033[0m"
done

echo -e "\033[31m\nUnreachable Servers:\033[0m"
for server in "${UNREACHABLE_SERVERS[@]}"; do
    echo -e "\033[31m$server\033[0m"
done

# Summary
echo -e "\nSummary:"
echo "========"
echo -e "Available Servers: \033[32m${#SUCCESS_SERVERS[@]}\033[0m"
echo -e "Unreachable Servers: \033[31m${#UNREACHABLE_SERVERS[@]}\033[0m"
