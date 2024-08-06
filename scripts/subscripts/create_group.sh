#! /bin/bash

source config.sh



create_group() {
    clear
    echo "Create a group ...."

    # Demander à l'utilisateur de fournir le chemin d'un fichier ou utiliser le fichier par défaut
    echo "Please select an option"
    echo  "1- Use groups.yaml.You can modify it in the playbook directory"
    echo  "2- Specify informations manually"
    read -r choice 

    case $choice in 
        1)
            groups_file="$PLAYBOOKS/groups.yaml"
            ;;
        2)
            # Ask for the number of users to be deployed

            # Initialize the output file
            output_file="$PLAYBOOKS/custom_groups.yaml"
            echo "groupes:" > "$output_file"

           
            read  -r -p "Enter groups names (comma-separated): " groups
                
                # Convert comma-separated groups to YAML format
            IFS=',' read -ra groups_array <<< "$groups"
                
                # Append the group information to the output file
            for group in "${groups_array[@]}"; do
                echo "  - nom: $group" >> "$output_file"
            done


            echo "Groups information has been saved to $output_file"
            groups_file=$output_file

            ;;

        *) echo "Invalid option" ;;
    esac


    # Check if the users_group file has been created

    if [ -f "$groups_file" ]; then
        # Vérifier si le fichier est au format spécifié

        if grep -q "groupes:" "$groups_file" && grep -q "nom:" "$groups_file" ; then
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
                    ansible-playbook -i "$servers", "$PLAYBOOKS"/add_delete_users_groups/create.yaml --extra-vars "action=addgroup utilisateurs_groupes_file=$user_groups_file"

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
                            ansible-playbook -i "$INVENTORIES"/nodes/"$active_node"/group_vars/lan.ini  "$PLAYBOOKS"/add_delete_users_groups/create.yaml --extra-vars "action=addgroup utilisateurs_groupes_file=$user_groups_file"
                                                     
                            ;;
                        2)
                            echo "Deployment on $active_node DMZ" 
                            ansible-playbook -i "$INVENTORIES"/nodes/"$active_node"/group_vars/dmz.ini  "$PLAYBOOKS"/add_delete_users_groups/create.yaml --extra-vars "action=addgroup utilisateurs_groupes_file=$user_groups_file"

                            ;;
                        3)
                            echo "Deployment on $active_node WAN" 
                            ansible-playbook -i "$INVENTORIES"/nodes/"$active_node"/group_vars/wan.ini  "$PLAYBOOKS"/add_delete_users_groups/create.yaml --extra-vars "action=addgroup utilisateurs_groupes_file=$user_groups_file"

                            ;;
                        4)
                            echo "Deployment on all servers of $active_node " 
                            ansible-playbook -i "$INVENTORIES"/nodes/"$active_node"/hosts  "$PLAYBOOKS"/add_delete_users_groups/create.yaml --extra-vars "action=addgroup utilisateurs_groupes_file=$user_groups_file"

                            ;;
                        *)
                            echo "Invalid choice"
                        ;;
                    esac

                    ;;

                    
                 
                3)
                    
                    #Action
                    ansible-playbook -i "$INVENTORIES"/all.ini playbooks/add_delete_users_groups/create.yaml --extra-vars "action=addgroup utilisateurs_groupes_file=$user_groups_file"

                    echo "Deployment successful"
                    ;;
                *)
                    echo "Invalid choice"
                            ;;
            esac
            
        else
            echo "The file '$groups_file' has invalid format"
        fi
    else
        echo "The $groups_file doesn't exist."
    fi
}


create_group