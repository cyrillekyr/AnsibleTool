#! /bin/bash

source config.sh



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
            user_groups_file="../playbooks/utilisateurs_groupes.yaml"
            ;;
        2)
            # Ask for the number of users to be deployed
            read -r -p "How many users will be deployed? " num_users

            # Initialize the output file
            output_file="../playbooks/custom_utilisateurs_groupes.yaml"
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
                    ansible-playbook -i "$servers", playbooks/add_delete_users_groups/create.yaml --extra-vars "action=adduser utilisateurs_groupes_file=$user_groups_file"

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

                            ;;
                        2)
                            echo "Deployment on $active_node DMZ" 
                            ;;
                        3)
                            echo "Deployment on $active_node WAN" 
                            ;;
                        4)
                            echo "Deployment on all servers of $active_node " 
                            ;;
                        *)
                            echo "Invalid choice"
                        ;;
                    esac

                    ;;

                    
                 
                3)
                    
                    #Action
                    #ansible-playbook -i $inventaire, playbooks/add_delete_users_groups/create.yaml --extra-vars "action=adduser utilisateurs_groupes_file=$fichier_machine"

                    echo "Deployment successful"
                    ;;
                *)
                    echo "Invalid choice"
                            ;;
            esac
            
        else
            echo "The file '$user_groups_file' has invalid format"
        fi
    else
        echo "The $user_groups_file doesn't exist."
    fi
}


deployer_user