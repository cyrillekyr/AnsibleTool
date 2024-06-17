#!/bin/bash

# Fonction pour afficher le menu principal
afficher_menu_principal() {
    clear
    echo "
#####                          #                                         
#     # ###### #####  #    #   # #   #    #  ####  # #####  #      ###### 
#       #      #    # #    #  #   #  ##   # #      # #    # #      #      
 #####  #####  #    # #    # #     # # #  #  ####  # #####  #      #####  
      # #      #####  #    # ####### #  # #      # # #    # #      #      
#     # #      #   #   #  #  #     # #   ## #    # # #    # #      #      
 #####  ###### #    #   ##   #     # #    #  ####  # #####  ###### ######                                                                                         
                                                                                                  
                                                                                               
"

    echo "Bienvenue dans l'outil d'automatisation de gestion de serveurs avec Ansible"
    echo "Select an option :"
    echo "1. Deploy an user"
    echo "2. Remove an user"
    echo "3. Create groups"
    echo "4. Delete groups"
    echo "5. Set a new server"
    echo "6. Remove a server"
    echo "7. Add a host"
    echo "8. Add a playbook"
    echo "9. Delete a playbook"
    echo "10. Update a host"
    echo "11. Dynamic inventory"
    echo "12. Settings"
    echo "0. Quit"
    echo -n "Select a number: "
}

# Fonction pour exécuter une action en fonction du choix de l'utilisateur
executer_action() {
    read choix
    case $choix in
        1) deployer_utilisateur ;;
        2) supprimer_utilisateur ;;
        3) ajouter_groupe ;;
        4) supprimer_groupe ;;
        5) deployer_machine ;;
        6) supprimer_machine ;;
        7) ajouter_hote ;;
        8) ajouter_playbook ;;
        9) supprimer_playbook ;;
        10) mettre_a_jour_hote ;;
        11) faire_inventaire ;;
        12) settings ;;
        0) exit ;;
        *) echo "Choix invalide. Veuillez sélectionner une option valide." ;;
    esac
}

# Fonctions pour implémenter les actions



# Deploy a user 


deployer_utilisateur() {
    clear
    echo "Déployer un utilisateur" 

    # Demander à l'utilisateur de fournir le chemin d'un fichier ou utiliser le fichier par défaut
    echo -n "Veuillez fournir le chemin du fichier contenant les informations de déploiement (laissez vide pour utiliser le fichier par défaut 'utilisateurs_groupes.yml') : "
    read -r fichier_machine_path

    # Vérifier si l'utilisateur a fourni un chemin de fichier ou utiliser le fichier par défaut
    if [ -z "$fichier_machine_path" ]; then
        fichier_machine="playbooks/utilisateurs_groupes.yaml"
    else
        fichier_machine="$fichier_machine_path"
    fi

    # Vérifier si le fichier machine existe
    if [ -f "$fichier_machine" ]; then
        # Vérifier si le fichier est au format spécifié

        if grep -q "utilisateurs:" "$fichier_machine" && grep -q "nom:" "$fichier_machine" && grep -q "groupes:" "$fichier_machine"; then
            inventaire="hosts/inventory.yaml"
            echo "Cible : "
            echo "1- Serveurs spécifiques"
            echo "2- Spécifier un fichier d'inventaire"
            echo "3- Utiliser le fichier par défaut (inventory.yaml)"
            echo -n "Votre choix : "
            read -r choix_cible

            case $choix_cible in
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
            echo "Le fichier '$fichier_machine' n'est pas au format spécifié."
        fi
    else
        echo "Le fichier '$fichier_machine' n'existe pas."
    fi
}

# Remove a user

supprimer_utilisateur() {
    clear
    echo "Delete a user"

    # Demander à l'utilisateur de fournir le chemin d'un fichier ou utiliser le fichier par défaut
    echo -n "Veuillez fournir le chemin du fichier contenant les informations de déploiement (laissez vide pour utiliser le fichier par défaut 'utilisateurs_groupes.yaml') : "
    read -r fichier_machine_path

    # Vérifier si l'utilisateur a fourni un chemin de fichier ou utiliser le fichier par défaut
    if [ -z "$fichier_machine_path" ]; then
        fichier_machine="playbooks/utilisateurs_groupes.yaml"
    else
        fichier_machine="$fichier_machine_path"
    fi

    # Vérifier si le fichier machine existe
    if [ -f "$fichier_machine" ]; then
        # Vérifier si le fichier est au format spécifié

        if grep -q "utilisateurs:" "$fichier_machine" && grep -q "nom:" "$fichier_machine" && grep -q "groupes:" "$fichier_machine"; then
            inventaire="hosts/inventory.yaml"
            echo "Cible : "
            echo "1- Serveurs spécifiques"
            echo "2- Spécifier un fichier d'inventaire"
            echo "3- Utiliser le fichier par défaut (inventory.yaml)"
            echo -n "Votre choix : "
            read -r choix_cible

            case $choix_cible in
                1)
                    # Demander à l'utilisateur de spécifier les serveurs spécifiques
                    echo -n "Veuillez spécifier les serveurs spécifiques (séparés par des virgules) : "
                    read -r serveurs_specifiques
                    echo $serveurs_specifiques
                    # Action
                    echo "La machine a été déployée avec succès."
                    ;;
                2)
                    # Demander à l'utilisateur de spécifier le chemin du fichier d'inventaire
                    echo -n "Veuillez fournir le chemin du fichier d'inventaire : "
                    read -r fichier_inventaire
                    if [ -f "$fichier_inventaire" ]; then

                        # Action
                        echo "Le groupe a été crée succès."
                    else   
                        echo "Le fichier spécifié n'existe pas"
                    fi
                    ;;
                3)
                    cat $inventaire
                    #Action
                    echo "Le groupe a été crée avec succès."
                    ;;
                *)
                    echo "Choix invalide. Arret."
                            ;;
            esac
            
        else
            echo "Le fichier '$fichier_machine' n'est pas au format spécifié."
        fi
    else
        echo "Le fichier '$fichier_machine' n'existe pas."
    fi

}

# Add a group
ajouter_groupe() {
    clear

    # Demander à l'utilisateur de saisir le nom du groupe
    echo -n "Veuillez saisir le nom du groupe à ajouter (séparez les noms par des virgules si plusieurs) : "
    read -r group_names

    # Écraser le contenu du fichier YAML avec les nouveaux groupes
    echo "groupes:" > playbooks/groupes.yml
    IFS=',' read -ra groups <<< "$group_names"
    for group in "${groups[@]}"; do
        echo "  - nom: $group" >> playbooks/groupes.yml
    done

    echo "Le fichier YAML 'groupes.yml' a été mis à jour avec les nouveaux groupes."

    inventaire="hosts/inventory.yaml"
    echo "Cible : "
    echo "1- Serveurs spécifiques"
    echo "2- Spécifier un fichier d'inventaire"
    echo "3- Utiliser le fichier par défaut (inventory.yaml)"
    echo -n "Votre choix : "
    read -r choix_cible

    case $choix_cible in
        1)
            # Demander à l'utilisateur de spécifier les serveurs spécifiques
            echo -n "Veuillez spécifier les serveurs spécifiques (séparés par des virgules) : "
            read -r serveurs_specifiques
            echo $serveurs_specifiques
            # Action
            echo "La machine a été déployée avec succès."
            ;;
        2)
            # Demander à l'utilisateur de spécifier le chemin du fichier d'inventaire
            echo -n "Veuillez fournir le chemin du fichier d'inventaire : "
            read -r fichier_inventaire
            if [ -f "$fichier_inventaire" ]; then

                # Action
                echo "Le groupe a été crée succès."
            else   
                echo "Le fichier spécifié n'existe pas"
            fi
            ;;
        3)
            cat $inventaire
            #Action
            echo "Le groupe a été crée avec succès."
            ;;
        *)
            echo "Choix invalide. Arret."
                    ;;
    esac


}

# Delete a group 
supprimer_groupe() {
    clear

    # Demander à l'utilisateur de saisir le nom du groupe
    echo -n "Veuillez saisir le nom du groupe à supprimer (séparez les noms par des espaces si plusieurs) : "
    read -r group_names

    # Écraser le contenu du fichier YAML avec les nouveaux groupes
    echo "groupes:" > playbooks/groupes.yml
    IFS=',' read -ra groups <<< "$group_names"
    for group in "${groups[@]}"; do
        echo "  - nom: $group" >> playbooks/groupes.yml
    done

    echo "Le fichier YAML 'groupes.yml' a été mis à jour avec les nouveaux groupes."
    inventaire="hosts/inventory.yaml"
    echo "Cible : "
    echo "1- Serveurs spécifiques"
    echo "2- Spécifier un fichier d'inventaire"
    echo "3- Utiliser le fichier par défaut (inventory.yaml)"
    echo -n "Votre choix : "
    read -r choix_cible

    case $choix_cible in
        1)
            # Demander à l'utilisateur de spécifier les serveurs spécifiques
            echo -n "Veuillez spécifier les serveurs spécifiques (séparés par des virgules) : "
            read -r serveurs_specifiques
            echo $serveurs_specifiques
            # Action
            echo "La machine a été déployée avec succès."
            ;;
        2)
            # Demander à l'utilisateur de spécifier le chemin du fichier d'inventaire
            echo -n "Veuillez fournir le chemin du fichier d'inventaire : "
            read -r fichier_inventaire
            if [ -f "$fichier_inventaire" ]; then

                # Action
                echo "Le groupe a été crée succès."
            else   
                echo "Le fichier spécifié n'existe pas"
            fi
            ;;
        3)
            cat $inventaire
            #Action
            echo "Le groupe a été crée avec succès."
            ;;
        *)
            echo "Choix invalide. Arret."
            ;;
        esac

}


#Deploy a machine
deployer_machine() {
    clear
    echo "Déployer une machine"

    inventaire="hosts/inventory.yaml"
    echo "Cible : "
    echo "1- Serveurs spécifiques"
    echo "2- Spécifier un fichier d'inventaire"
    echo "3- Utiliser le fichier par défaut (inventory.yaml)"
    echo -n "Votre choix : "
    read -r choix_cible

    case $choix_cible in
            1)
                # Demander à l'utilisateur de spécifier les serveurs spécifiques
                echo -n "Veuillez spécifier les serveurs spécifiques (séparés par des virgules) : "
                read -r serveurs_specifiques
                echo $serveurs_specifiques
                # Action
                echo "L'opération a été réalisée avec succès."
                ;;
            2)
                # Demander à l'utilisateur de spécifier le chemin du fichier d'inventaire
                echo -n "Veuillez fournir le chemin du fichier d'inventaire : "
                read -r fichier_inventaire
                if [ -f "$fichier_inventaire" ]; then
                    # Action
                    echo "L'opération a été réalisée avec succès."
                else   
                    echo "Le fichier spécifié n'existe pas"
                fi
                ;;
            3)
                cat $inventaire
                #Action
                echo "L'operation a été réalisée avec succès "
                ;;
            *)
                echo "Choix invalide. Arret."
                        ;;
    esac
}


supprimer_machine() {
        clear
    echo "Supprimer une machine"

    inventaire="hosts/inventory.yaml"
    echo "Cible : "
    echo "1- Serveurs spécifiques"
    echo "2- Spécifier un fichier d'inventaire"
    echo "3- Utiliser le fichier par défaut (inventory.yaml)"
    echo -n "Votre choix : "
    read -r choix_cible

    case $choix_cible in
            1)
                # Demander à l'utilisateur de spécifier les serveurs spécifiques
                echo -n "Veuillez spécifier les serveurs spécifiques (séparés par des virgules) : "
                read -r serveurs_specifiques
                echo $serveurs_specifiques
                # Action
                echo "L'opération a été réalisée avec succès."
                ;;
            2)
                # Demander à l'utilisateur de spécifier le chemin du fichier d'inventaire
                echo -n "Veuillez fournir le chemin du fichier d'inventaire : "
                read -r fichier_inventaire
                if [ -f "$fichier_inventaire" ]; then
                    # Action
                    echo "L'opération a été réalisée avec succès."
                else   
                    echo "Le fichier spécifié n'existe pas"
                fi
                ;;
            3)
                cat $inventaire
                #Action
                echo "L'operation a été réalisée avec succès "
                ;;
            *)
                echo "Choix invalide. Arret."
                        ;;
    esac

}


settings() {
    clear
    echo "  Aministration Panel"

    echo "1. Playbooks Settings"
    echo "2. Inventory settings"
    echo "3. Customization"
    read -r choix

    case $choix in  
        1)
            echo "1. List and describe all playbooks"
            echo "2. Add a playbook"
            echo "3. Delete a playbook"
            echo "4. Update a playbook"
            read -r case1

            case $case1 in
                1)
                    bash scripts/list_and_describe_playbooks.sh
                    ;;
                2) 
                    ;;
                3)
                    ;;
                4)
                    ;;
                
            esac

            ;;


        2)
            echo "1. List inventory hosts"
            echo "2. Check hosts availability"
            echo "3. Add a host"
            echo "4. Delete a host" 
            echo "5. Update a host"

            read -r case2

            case $case1 in 
                1)
                    cat hosts/inventory.yaml 
                    echo \n
                    ;;

                2)
                    bash scripts/host_availibility_checker.sh
                    ;;

                3) 
                    ;;

                4)
                    ;;

                5)
                    ;;

            esac



            
            ;;


        3)
            #Add custom functions here
            ;;

        *)
            echo  "Invalid choice, Arret"
            ;;

    esac


    
}


# Ajoutez les autres fonctions pour les actions restantes

# Fonction principale pour exécuter le script
main() {
    while true; do
        afficher_menu_principal
        executer_action
        echo ""
        echo -n "Appuyez sur Entrée pour revenir au menu principal..."
        read input
    done
}

# Exécution du script
main
