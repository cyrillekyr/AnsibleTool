#!/bin/bash

source config.sh
source main_funcs.sh

# Function to validate if the file is a correct YAML playbook
validate_playbook() {
    playbook_path="$1"
    
    # Check if the file exists
    if [ ! -f "$playbook_path" ]; then
        echo "Error: File does not exist."
        log_action "Playbook $playbook_path validation failed - File not found"
        exit 1
    fi
    
    # Check if the file is a YAML file
    if ! [[ "$playbook_path" == *.yaml || "$playbook_path" == *.yml ]]; then
        echo "Error: The provided file is not a YAML file."
        log_action "Playbook $playbook_path validation failed - Invalid file type"
        exit 1
    fi
    
    # Check if the file starts with the correct YAML syntax for an Ansible playbook
    if ! grep -q '---' "$playbook_path"; then
        echo "Error: The file does not appear to be a valid Ansible playbook."
        log_action "Playbook $playbook_path validation failed - Incorrect YAML format"
        exit 1
    fi
    
    log_action "Playbook $playbook_path validation successful"
    echo "Playbook validation successful."

   
}

# Function to execute the playbook
execute_playbook() {
    playbook_path="$1"
    
    # Run the playbook with Ansible
    ansible-playbook "$playbook_path"
    
    if [ $? -eq 0 ]; then
        echo "Target : "
        echo "1- Specific servers"
        echo "2- Group"
        echo "3- All servers"
        read -r -p "Your choice: " target

        run_dynamic_inventory

        case $target in
            1)
                # Demander à l'utilisateur de spécifier les serveurs spécifiques
                echo -n "Please specify the specific servers (comma separated): "
                read -r servers
                echo "$servers"
                # Action
                ansible-playbook -i "$servers", "$playbook_path"

                log_action "Deployment of users on  $servers"
                echo "Deployment successfull !!!"
                ;;
            2)
                # Demander à l'utilisateur de spécifier le chemin du fichier d'inventaire
    
                # Charger les noeuds et groupes depuis le fichier config.json sans utiliser jq
                config_file="../inventories/dynamic/config.json"
                nodes=$(grep -oP '"noeud":\s*"\K[^"]+' "$config_file" | tr '\n' ' ')
                        
                        
                echo "Please specify the node"
                index=1
                for node in $nodes; do
                    echo "$index- $node"
                    index=$((index+1))
                done
                        

                        
                num_nodes=$(echo "$nodes" | wc -w)
                read -r node_choice
                if [[ $node_choice -ge 1 && $node_choice -le $num_nodes ]]; then                        
                    active_node=$(echo "$nodes" | awk -v choice="$node_choice" '{print $choice}')
                            
                else
                    echo "Invalid node choice"
                    exit 1
                fi

                        
                groups=$(sed -n '/"groups": \[/,/\]/p' "$config_file" | tr -d '\n' | sed 's/.*\[//;s/\].*//;s/[",]//g')


                echo "($active_node) Please specify a group"

                # Afficher dynamiquement les options de groupe
                index=1
                for group in $groups; do
                    echo "$index-($active_node) $group"
                    index=$((index+1))
                done
                echo "$index-($active_node) ALL"
                num_groups=$(echo "$groups" | wc -w)

                # Lire le choix de l'utilisateur
                read -r choice


                # Traiter le choix
                if [[ $choice -ge 1 && $choice -le $num_groups ]]; then
                    selected_group=$(echo "$groups" | awk -v choice=$choice '{print $choice}' | tr '[:upper:]' '[:lower:]')
                    echo $selected_group
                    echo "Deployment on $active_node $selected_group"
                    ansible-playbook -i "$INVENTORIES"/nodes/"$active_node"/group_vars/"$selected_group".hosts "$playbook_path"
                    log_action "$role on $active_node $selected_group"
                elif [[ $choice -eq $index ]]; then
                    echo "Deployment on all servers of $active_node"
                    ansible-playbook -i "$INVENTORIES"/nodes/"$active_node"/hosts "$playbook_path"
                    log_action "$role on all servers of $active_node"
                else
                    echo "Invalid choice"
                fi

                ;;   
                    
            3)
                        
                #Action
                ansible-playbook -i "$INVENTORIES"/all.hosts "$playbook_path"
                log_action "$role on all servers"
                echo "Deployment successful"
                ;;
            *)
                echo "Invalid choice"
                        ;;
        esac
    else
        echo "Error: Playbook execution failed."
        log_action "Playbook execution failed"
        exit 1
    fi
}

# Main function for executing the playbook
execute_playbook_main() {
    echo "Please provide the full path to the Ansible playbook:"
    read -r playbook_path

    while true; do
        echo "Specify the role of the playbook (e.g., Users Deployment):"
        read -r role

        # Validate the role format (only letters and spaces allowed)
        if [[ "$role" =~ ^[a-zA-Z\ ]+$ ]]
        then
            break
        else
            echo "Invalid role format. Please use only letters and spaces."
        fi
    done
    
    # Validate the playbook file
    validate_playbook "$playbook_path"
    
    # Execute the playbook if validation is successful
    execute_playbook "$playbook_path"
}

# Execute the script
execute_playbook_main
