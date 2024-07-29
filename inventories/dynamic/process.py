import json

# Charger les données JSON
with open('message.txt') as file:
    data = json.load(file)

# Préparer les groupes
groups = {
    "LAN": [],
    "DMZ": [],
    "WAN": []  # Ajouter ici les hôtes du groupe WAN si nécessaire
}

# Parcourir les hôtes et les ajouter aux groupes appropriés
for host, details in data["_meta"]["hostvars"].items():
    if "kali" in host or "bastion" in host:
        continue  # Exclure les hôtes "kali" et "bastion"
    if "lan" in details["proxmox_tags"]:
        ip_address = f"192.168.1.{details['proxmox_vmid']}"
        groups["LAN"].append(f"{host} ansible_host={ip_address}")
    if "dmz" in details["proxmox_tags"]:
        groups["DMZ"].append(f"{host} ansible_host={host}")
    # Ajouter ici la condition pour le groupe WAN si nécessaire

# Générer le fichier d'inventaire Ansible principal
inventory = []

for group, hosts in groups.items():
    inventory.append(f"[{group}]")
    inventory.extend(hosts)
    inventory.append("")  # Ajouter une ligne vide entre les groupes

# Ajouter la section [ALL:children]
inventory.append("[ALL:children]")
inventory.append("LAN")
inventory.append("DMZ")
inventory.append("WAN")
inventory.append("")

# Écrire le fichier d'inventaire principal
with open('ansible_inventory.ini', 'w') as file:
    file.write("\n".join(inventory))

# Écrire les fichiers pour chaque groupe
for group, hosts in groups.items():
    with open(f'group_vars/{group.lower()}.ini', 'w') as file:
        file.write("\n".join(hosts))

print("Les fichiers d'inventaire Ansible ont été générés avec succès.")
