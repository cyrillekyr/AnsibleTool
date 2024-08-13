#! /bin/bash

source config.sh
source logger.sh



remove_user() {
    clear
    echo "Remove a user ...."

    # Demander à l'utilisateur de fournir le chemin d'un fichier ou utiliser le fichier par défaut
    echo "Please select an option"
    echo  "1- Use users.yaml.You can modify it in the playbook directory"
    echo  "2- Specify informations manually"
    read -r choice 

    case $choice in 
        1)
            users_file="$PLAYBOOKS/users.yaml"
            ;;
        2)
            # Ask for the number of users to be deployed

            # Initialize the output file
            output_file="$PLAYBOOKS/custom_users.yaml"
            echo "utilisateurs:" > "$output_file"

            # Loop through the number of users and collect their information
            read  -r -p "Enter users names (comma-separated): " users
                
                # Convert comma-separated groups to YAML format
            IFS=',' read -ra users_array <<< "$users"
                
                # Append the user information to the output file
            for user in "${users_array[@]}"; do
                echo "  - nom:  $user" >> "$output_file"
            done


            echo "User information has been saved to $output_file"
            users_file=$output_file

            ;;

        *) echo "Invalid option" ;;
    esac


    # Check if the users_group file has been created

    if [ -f "$users_file" ]; then
        # Vérifier si le fichier est au format spécifié

        if grep -q "utilisateurs:" "$users_file" && grep -q "nom:" "$users_file" ; then
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
                    ansible-playbook -i "$servers", "$PLAYBOOKS"/add_delete_users_groups/create.yaml --extra-vars "action=deluser utilisateurs_groupes_file=$users_file"
                    log_action "Deletion of users from $servers "

                    echo "Deployment successfull !!!"
                    ;;
                2)
                    # Demander à l'utilisateur de spécifier le chemin du fichier d'inventaire
                    echo "Please specify the node  : "
                    nodes=$(ls "$INVENTORIES/nodes")
                    i=1
                    for node in $nodes
                    do
                        echo "$i- $node"
                        ((i++))
                    done

                    read -r nd 
                    i=1
                    for node in $nodes
                    do
                        if [ $i -eq "$nd" ]; then
                            active_node=$node
                            break
                        fi
                        ((i++))
                    done

                    echo  "($active_node) Please specify the group"
                    echo  "1-($active_node) LAN"
                    echo  "2-($active_node) DMZ"
                    echo  "3-($active_node) WAN"
                    echo  "4-($active_node) ALL"

                    read -r choice
                    case $choice in
                        1)
                            echo "Deployment on $active_node LAN" 
                            ansible-playbook -i "$INVENTORIES"/nodes/"$active_node"/group_vars/lan.ini  "$PLAYBOOKS"/add_delete_users_groups/create.yaml --extra-vars "action=deluser utilisateurs_groupes_file=$user_groups_file"
                            log_action "Deletion of users from $active_node LAN "
                                                     
                            ;;
                        2)
                            echo "Deployment on $active_node DMZ" 
                            ansible-playbook -i "$INVENTORIES"/nodes/"$active_node"/group_vars/dmz.ini  "$PLAYBOOKS"/add_delete_users_groups/create.yaml --extra-vars "action=deluser utilisateurs_groupes_file=$user_groups_file"
                            log_action "Deletion of users from $active_node DMZ "

                            ;;
                        3)
                            echo "Deployment on $active_node WAN" 
                            ansible-playbook -i "$INVENTORIES"/nodes/"$active_node"/group_vars/wan.ini  "$PLAYBOOKS"/add_delete_users_groups/create.yaml --extra-vars "action=deluser utilisateurs_groupes_file=$user_groups_file"
                            log_action "Deletion of users from $active_node WAN "

                            ;;
                        4)
                            echo "Deployment on all servers of $active_node " 
                            ansible-playbook -i "$INVENTORIES"/nodes/"$active_node"/hosts  "$PLAYBOOKS"/add_delete_users_groups/create.yaml --extra-vars "action=deluser utilisateurs_groupes_file=$user_groups_file"
                            log_action "Deletion of users from $active_node servers "

                            ;;
                        *)
                            echo "Invalid choice"
                        ;;
                    esac

                    ;;

                    
                 
                3)
                    
                    #Action
                    ansible-playbook -i "$INVENTORIES"/all.ini playbooks/add_delete_users_groups/create.yaml --extra-vars "action=deluser utilisateurs_groupes_file=$user_groups_file"

                    echo "Deployment successful"
                    log_action "Deletion of users from all servers "

                    ;;
                *)
                    echo "Invalid choice"
                            ;;
            esac
            
        else
            echo "The file '$user_groups_file' has invalid format"
            log_action "Error: The file '$user_groups_file' has invalid format"

        fi
    else
        echo "The file $user_groups_file doesn't exist."
        log_action "Error: The file $user_groups_file doesn't exist."
    fi
}


remove_user