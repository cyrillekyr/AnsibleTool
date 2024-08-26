import json
import os
import datetime
import getpass


def log_action(action, log_file='../playbooks/action_log'):
    """
    Log an action to a specified log file with a timestamp and user information.
    
    :param action: The action description to log.
    :param log_file: Path to the log file. Defaults to './action_log'.
    """
    # Ensure the log directory exists
    os.makedirs(os.path.dirname(log_file), exist_ok=True)
    
    # Get current time and user
    current_time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    user = getpass.getuser()
    
    # Format the log message
    log_message = f"{current_time} | User: {user} | Action: {action}\n"
    
    # Append the log message to the log file
    with open(log_file, 'a') as file:
        file.write(log_message)


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
        log_action(log_text)
    else:
        config['groups'].append(normalized_group)
        print(f"The group '{new_group}' has been added.")
        log_text = "The group var " + new_group + " has been added"
        log_action(log_text)

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
        log_action(log_text)
    else:
        print(f"The group '{group_to_remove}' does not exist.")
        log_text = "Error while removing the group var " + group_to_remove + " : The group does not exist"
        log_action(log_text)

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
