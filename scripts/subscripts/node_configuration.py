import json
import os
import subprocess

CONFIG_FILE = '../inventories/dynamic/config.json'
DYNAMIC_SCRIPT = '../inventories/dynamic/dynamic_inventory.sh'


def load_config():
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, 'r') as file:
            return json.load(file)
    else:
        return {"nodes": [], "groups": []}


def save_config(config):
    with open(CONFIG_FILE, 'w') as file:
        json.dump(config, file, indent=4)


def update_dynamic_script(config):
    with open(DYNAMIC_SCRIPT, 'w') as file:
        file.write("#! /bin/bash\n\n")
        for node in config['nodes']:
            if 'url' in node and 'username' in node and 'password' in node:
                command = (
                    f"python3 proxmox.py --url={node['url']} --username={node['username']} "
                    f"--password={node['password']} --trust-invalid-certs --list --pretty > ../inventories/dynamic/{node['noeud'].lower()}.json\n"
                )
                file.write(command)
            else:
                print(f"Warning: Node '{node['noeud']}' is missing URL, username, or password. Skipping in script.")
        file.write("\npython3 process.py\n")


def execute_dynamic_script():
    subprocess.run(["bash", DYNAMIC_SCRIPT])


def add_node(config):
    noeud = input("Enter the node name (e.g., Wano): ")
    json_file = f"{noeud.lower()}.json"
    username = input("Enter the Proxmox username: ")
    password = input("Enter the Proxmox password: ")
    url = input("Enter the Proxmox URL: ")

    # Add the new node to the config
    config['nodes'].append({
        "json_file": json_file,
        "noeud": noeud,
        "username": username,
        "password": password,
        "url": url
    })

    save_config(config)
    update_dynamic_script(config)
    execute_dynamic_script()
    print(f"The node '{noeud}' has been successfully added with the JSON file '{json_file}'.")


def configure_node(config):
    noeud = input("Enter the name of the node to configure: ")
    node = next((node for node in config['nodes'] if node['noeud'] == noeud), None)

    if not node:
        print("Node not found.")
        return

    print("Leave blank to keep the current value.")
    username = input(f"Username [{node['username']}] : ") or node['username']
    password = input(f"Password [{node['password']}] : ") or node['password']
    url = input(f"URL [{node['url']}] : ") or node['url']

    # Update the node information
    node['username'] = username
    node['password'] = password
    node['url'] = url

    save_config(config)
    update_dynamic_script(config)
    execute_dynamic_script()
    print(f"The node '{noeud}' has been successfully configured.")


def delete_node(config):
    noeud = input("Enter the name of the node to delete: ")
    node = next((node for node in config['nodes'] if node['noeud'] == noeud), None)

    if not node:
        print("Node not found.")
        return

    config['nodes'].remove(node)
    save_config(config)
    update_dynamic_script(config)

    # Remove the node directory
    node_dir = f"nodes/{noeud}"
    if os.path.exists(node_dir):
        os.system(f"rm -rf {node_dir}")

    execute_dynamic_script()
    print(f"The node '{noeud}' has been successfully deleted.")


def main():
    config = load_config()

    action = input("Would you like to add, configure, or delete a node? (add/configure/delete): ").strip().lower()

    if action == "add":
        add_node(config)
    elif action == "configure":
        configure_node(config)
    elif action == "delete":
        delete_node(config)
    else:
        print("Unrecognized action. Please choose 'add', 'configure', or 'delete'.")


if __name__ == "__main__":
    main()