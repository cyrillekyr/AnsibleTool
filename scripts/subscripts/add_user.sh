#! /bin/bash

source config.sh
source logger.sh



deployer_user() {
    clear
    echo "Add a user ...."

    # Demander à l'utilisateur de fournir le chemin d'un fichier ou utiliser le fichier par défaut
    echo "Please select an option"
    echo  "1- Use utilisateurs_groupes.yaml.You can modify it in the playbook directory"
    echo  "2- Specify informations manually"
    read -r choice 

    case $choice in 
        1)
            user_groups_file="$PLAYBOOKS/utilisateurs_groupes.yaml"
            ;;
        2)
            # Ask for the number of users to be deployed
            read -r -p "How many users will be deployed? " num_users

            # Initialize the output file
            output_file="$PLAYBOOKS/custom_utilisateurs_groupes.yaml"
            echo "utilisateurs:" > $output_file

            # Loop through the number of users and collect their information
            for ((i=1; i<=num_users; i++)); do
                read -r -p "Enter name for user $i: " user_name
                read  -r -p "Enter groups for $user_name (comma-separated): " user_groups
                
                # Convert comma-separated groups to YAML format
                IFS=',' read -ra groups_array <<< "$user_groups"
                
                # Append the user information to the output file
                echo "  - nom: $user_name" >> $output_file
                echo "    groupes:" >> $output_file
                for group in "${groups_array[@]}"; do
                    echo "      - $group" >> $output_file
                done
            done

            echo "User information has been saved to $output_file"
            user_groups_file=$output_file

            ;;

        *) echo "Invalid option" ;;
    esac


    # Check if the users_group file has been created

    if [ -f "$user_groups_file" ]; then
        # Vérifier si le fichier est au format spécifié

        if grep -q "utilisateurs:" "$user_groups_file" && grep -q "nom:" "$user_groups_file" && grep -q "groupes:" "$user_groups_file"; then
            echo "Target : "
            echo "1- Specific servers"
            echo "2- Group"
            echo "3- All servers"
            read -r -p "Your choice: " target

            case $target in
                1)
                    # Demander à l'utilisateur de spécifier les serveurs spécifiques
                    echo -n "Please specify the specific servers (comma separated): "
                    read -r servers
                    echo "$servers"
                    # Action
                    ansible-playbook -i "$servers", "$PLAYBOOKS"/user_management/create.yaml --extra-vars "action=adduser utilisateurs_groupes_file=$user_groups_file"

                    log_action "Deployment of users on  $servers"
                    echo "Deployment successfull !!!"
                    ;;
                2)
                    # Demander à l'utilisateur de spécifier le chemin du fichier d'inventaire
 
                    # Charger les noeuds et groupes depuis le fichier config.json sans utiliser jq
                    config_file="$SCRIPTS/config.json"
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

                    
                    groups=$(grep -oP '"groups":\s*\[\K[^\]]+' "$config_file" | tr -d '",' | tr '\n' ' ')
                    
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
                        ansible-playbook -i "$INVENTORIES"/nodes/"$active_node"/group_vars/"$selected_group".ini "$PLAYBOOKS"/user_management/create.yaml --extra-vars "action=adduser utilisateurs_groupes_file=$user_groups_file"
                        log_action "Deployment of users on $active_node $selected_group"
                    elif [[ $choice -eq $index ]]; then
                        echo "Deployment on all servers of $active_node"
                        ansible-playbook -i "$INVENTORIES"/nodes/"$active_node"/hosts "$PLAYBOOKS"/user_management/create.yaml --extra-vars "action=adduser utilisateurs_groupes_file=$user_groups_file"
                        log_action "Deployment of all users on all servers of $active_node"
                    else
                        echo "Invalid choice"
                    fi

                 ;;   
                 
                3)
                    
                    #Action
                    ansible-playbook -i "$INVENTORIES"/all.ini playbooks/user_management/create.yaml --extra-vars "action=adduser utilisateurs_groupes_file=$user_groups_file"
                    log_action "Deployment of users on all servers"
                    echo "Deployment successful"
                    ;;
                *)
                    echo "Invalid choice"
                            ;;
            esac
            
        else
            echo "The file '$user_groups_file' has invalid format"
            log_action "Error : The file '$user_groups_file' has invalid format "
        fi
    else
        echo "The file $user_groups_file doesn't exist."
        log_action "Error : The file '$user_groups_file' doesn't exist"
    fi
}


deployer_user