import json
import os

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
    else:
        config['groups'].append(normalized_group)
        print(f"The group '{new_group}' has been added.")

    save_config(config)


def remove_group(config):
    group_to_remove = input("Enter the name of the group to remove: ").strip()
    normalized_group = normalize_group_name(group_to_remove)

    groups_upper = [group.upper() for group in config['groups']]
    
    if normalized_group in groups_upper:
        index = groups_upper.index(normalized_group)
        removed_group = config['groups'].pop(index)
        print(f"The group '{removed_group}' has been removed.")
    else:
        print(f"The group '{group_to_remove}' does not exist.")

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
