#!/bin/bash

source config.sh
source logger.sh 



# Display welcome message

display_princal_menu()
{

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

    
    echo "Please select an option:"
    echo "1. Add a user"
    echo "2. Remove a user"
    echo "3. Create a group"
    echo "4. Delete a group"
    echo "5. Deploy a machine"
    echo "6. Remove a machine"
    echo "7. Execute a playbook"
    echo "8. Dynamic inventory"
    echo "9. Check machine availability"
    echo "10. Administration"
    echo "0. Exit"


}

execute_action()
{
    echo ""
    read -r choice

    case $choice in
    1) ./subscripts/add_user.sh ;;
    2) ./subscripts/remove_user.sh ;;
    3) ./subscripts/create_group.sh ;;
    4) ./subscripts/delete_group.sh ;;
    5) ./subscripts/new_server_deployment.sh ;;
    6) ./subscripts/remove_machine.sh ;;
    7) ./subscripts/execute_playbook.sh ;;
    8) ./subscripts/dynamic_inventory.sh ;;
    9) ./subscripts/check_availability.sh ;;
    10) ./subscripts/administration.sh ;;
    0) exit 0 ;;
    *) echo "Invalid option" ;;
esac


}




main() {
    while true; do
        display_princal_menu
        execute_action
        echo ""
        echo -n "Press enter to comme back to principal menu..."
        read -r input
    done
}

# Exécution du script
main
