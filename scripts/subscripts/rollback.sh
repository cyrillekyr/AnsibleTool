#! /bin/bash 

# Delete basic configurations


#Deploy a machine
deployer_machine() {
    clear
    echo "Delete basic configurations"

    echo "Target : "
    echo "1- Specific servers"
    echo "2- Group"
    echo "3- All servers"
    read -r -p "Your choice: " target

    case $target in
            1)
                # Provide the specific servers informations
                    # Demander à l'utilisateur de spécifier les serveurs spécifiques
                    echo -n "Please specify the specific servers (comma separated): "
                    read -r servers
                    echo "$servers"
                    # Action
                    

                    echo "Rollback successfull !!!"
                    ;;

            2)
                # Provide the group information
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
                            echo "Rollback on $active_node LAN" 

                            ;;
                        2)
                            echo "Rollback on $active_node DMZ" 
                            ;;
                        3)
                            echo "Rollback on $active_node WAN" 
                            ;;
                        4)
                            echo "Rollback on all servers of $active_node " 
                            ;;
                        *)
                            echo "Invalid choice"
                        ;;
                    esac

                    ;;                    
                 
                3)
                    
                    #Action
                    #ansible-playbook -i $inventaire, playbooks/add_delete_users_groups/create.yaml --extra-vars "action=adduser utilisateurs_groupes_file=$fichier_machine"

                    echo "Rollback successful"
                    ;;
                *)
                    echo "Invalid choice"
                            ;;
    esac
}