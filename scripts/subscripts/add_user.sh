#! /bin/bash

deployer_utilisateur() {
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
                    echo -n "Veuillez spécifier les serveurs spécifiques (séparés par des virgules) : "
                    read -r serveurs_specifiques
                    echo $serveurs_specifiques
                    # Action
                    ansible-playbook -i $serveurs_specifiques, playbooks/add_delete_users_groups/create.yaml --extra-vars "action=adduser utilisateurs_groupes_file=$fichier_machine"

                    echo "L'utilisateur a été déployé avec succès."
                    ;;
                2)
                    # Demander à l'utilisateur de spécifier le chemin du fichier d'inventaire
                    echo -n "Veuillez fournir le chemin du fichier d'inventaire : "
                    read -r fichier_inventaire
                    if [ -f "$fichier_inventaire" ]; then

                        # Action
                        ansible-playbook -i $fichier_inventaire, playbooks/add_delete_users_groups/create.yaml --extra-vars "action=adduser utilisateurs_groupes_file=$fichier_machine"

                        echo "L'utilisateur a été créé succès."
                    else   
                        echo "Le fichier spécifié n'existe pas"
                    fi
                    ;;
                3)
                    
                    #Action
                    ansible-playbook -i $inventaire, playbooks/add_delete_users_groups/create.yaml --extra-vars "action=adduser utilisateurs_groupes_file=$fichier_machine"

                    echo "Le groupe a été crée avec succès."
                    ;;
                *)
                    echo "Choix invalide. Arret."
                            ;;
            esac
            
        else
            echo "The file '$user_groups_file' has invalid format"
        fi
    else
        echo "Le fichier '$fichier_machine' n'existe pas."
    fi
}


deployer_utilisateur