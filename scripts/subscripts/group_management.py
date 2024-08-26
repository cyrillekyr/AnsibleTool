import json
import os
import subprocess


def call_main_functions(function_name, *args):
    script_path = "main_funcs.sh"
    
    try:
        # Build the command with the function name and arguments
        # Escape single quotes in args if necessary
        args_escaped = [arg.replace("'", "\\'") for arg in args]
        command = [script_path, function_name] + args_escaped
        
        # Execute the specific function in the bash script
        result = subprocess.run(command, capture_output=True, text=True, check=True)

        # Print the output and error (if any)
        print("Output:\n", result.stdout)
        if result.stderr:
            print("Errors:\n", result.stderr)
            
    except subprocess.CalledProcessError as e:
        print(f"An error occurred: {e}")


CONFIG_FILE = '../inventories/dynamic/config.json'


def load_config():
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, 'r') as file:
            return json.load(file)
    else:
        return {"nodes": [], "groups": []}


def save_config(config):
    with open(CONFIG_FILE, 'w') as file:
        json.dump(config, file, indent=4)


def normalize_group_name(group_name):
    return group_name.strip().upper()


def add_group(config):
    new_group = input("Enter the name of the group to add: ").strip()
    normalized_group = normalize_group_name(new_group)

    if normalized_group in (group.upper() for group in config['groups']):
        print(f"The group '{new_group}' already exists.")
        log_text = "Error while creating  the group var " + new_group + " : The group already exixts"
        call_main_functions("log_action", log_text)
    else:
        config['groups'].append(normalized_group)
        print(f"The group '{new_group}' has been added.")
        log_text = "The group var " + new_group + " has been added"
        call_main_functions("log_action", log_text)

    save_config(config)


def remove_group(config):
    group_to_remove = input("Enter the name of the group to remove: ").strip()
    normalized_group = normalize_group_name(group_to_remove)

    groups_upper = [group.upper() for group in config['groups']]
    
    if normalized_group in groups_upper:
        index = groups_upper.index(normalized_group)
        removed_group = config['groups'].pop(index)
        print(f"The group '{removed_group}' has been removed.")
        log_text = "The group var " + remove_group + " has been removed"
        call_main_functions("log_action", log_text)
    else:
        print(f"The group '{group_to_remove}' does not exist.")
        log_text = "Error while removing the group var " + group_to_remove + " : The group does not exist"
        call_main_functions("log_action", log_text)

    save_config(config)


def main():
    config = load_config()

    action = input("Would you like to add or remove a group? (add/remove): ").strip().lower()

    if action == "add":
        add_group(config)
    elif action == "remove":
        remove_group(config)
    else:
        print("Unrecognized action. Please choose 'add' or 'remove'.")


if __name__ == "__main__":
    main()
