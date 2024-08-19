#! /bin/bash 

# Deploy basic configurations on a new server
source config.sh
source logger.sh


#Deploy a machine
deployer_machine() {
    clear
    echo "Configure a new server"

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

                    ansible-playbook -i "$servers", $PLAYBOOKS/server_deployment/default.yaml
                    log_action "Default configurations deployed on $servers "

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
                        echo "Deployment on $active_node $selected_group" 
                        ansible-playbook -i "$INVENTORIES"/nodes/"$active_node"/group_vars/"$selected_group".ini "$PLAYBOOKS"/server_deployment/default.yaml
                        log_action "Default configurations deployed on $active_node $selected_group "
                    elif [[ $choice -eq $index ]]; then
                        echo "Deployment on all groups of $active_node"
                        ansible-playbook -i "$INVENTORIES"/nodes/"$active_node"/hosts "$PLAYBOOKS"/server_deployment/default.yaml
                        log_action "Deployment of all groups on all servers of $active_node"
                    else
                        echo "Invalid choice"
                    fi

                 ;;             
                 
                3)
                    
                    #Action
                    ansible-playbook -i "$INVENTORIES"/all.ini "$PLAYBOOKS"/server_deployment/default.yaml
                    log_action "Default configurations deployed all on servers"

                    echo "Deployment successful"
                    ;;
                *)
                    echo "Invalid choice"
                            ;;
    esac
}

deployer_machine