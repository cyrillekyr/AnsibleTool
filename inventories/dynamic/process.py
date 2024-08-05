import json
import os

# Fonction pour générer l'inventaire Ansible à partir d'un fichier JSON
def generer_inventaire(json_file, noeud):
    with open(json_file) as file:
        data = json.load(file)

    groups = {
        "LAN": [],
        "DMZ": [],
        "WAN": []  # Ajouter ici les hôtes du groupe WAN si nécessaire
    }

    for host, details in data["_meta"]["hostvars"].items():
        if "kali-bastion" in host:
            continue  # Exclure les hôtes "kali" et "bastion"
        if "lan" in details["proxmox_tags"]:
            groups["LAN"].append(f"{host} ansible_host={host}")
        if "dmz" in details["proxmox_tags"]:
            groups["DMZ"].append(f"{host} ansible_host={host}")
        # Ajouter ici la condition pour le groupe WAN si nécessaire

    inventory = [f"[{noeud}]"]

    for group, hosts in groups.items():
        inventory.append(f"[{noeud}:{group}]")
        inventory.extend(hosts)
        inventory.append("")  # Ajouter une ligne vide entre les groupes

    inventory.append(f"[{noeud}:children]")
    inventory.append(f"{noeud}:LAN")
    inventory.append(f"{noeud}:DMZ")
    inventory.append("")

    return inventory, groups

# Liste des fichiers JSON et des répertoires de sortie correspondants
fichiers = [
    ("wano.json", "wano"),
    ("narnia.json", "narnia")
]

all_inventory = []
node_names = []

# Générer les inventaires pour chaque fichier JSON
for json_file, noeud in fichiers:
    inventory, groups = generer_inventaire(json_file, noeud)
    node_names.append(noeud)
    
    output_dir = f"nodes/{noeud}"
    os.makedirs(output_dir, exist_ok=True)
    
    with open(os.path.join(output_dir, 'hosts'), 'w') as file:
        file.write("\n".join(inventory))
    
    os.makedirs(os.path.join(output_dir, 'group_vars'), exist_ok=True)
    
    for group, hosts in groups.items():
        with open(os.path.join(output_dir, f'group_vars/{group.lower()}.ini'), 'w') as file:
            file.write("\n".join(hosts))
    
    all_inventory.extend(inventory)

all_inventory.append("")
all_inventory.append("[ALL:children]")
all_inventory.extend(node_names)

with open('all.ini', 'w') as file:
    file.write("\n".join(all_inventory))

print("Les fichiers d'inventaire Ansible ont été générés avec succès pour tous les noeuds et l'inventaire total.")
