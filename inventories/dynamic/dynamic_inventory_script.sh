#! /bin/bash 

source config.sh

python /etc/ansible/proxmox.py   --url=https://37.187.77.208:8006/   --username=root@pam   --password=KimtfuZV1hcFlOlm  --trust-invalid-certs   --list --pretty > "$INVENTORIES"/dynamic/wano.json


python /etc/ansible/proxmox.py   --url=https://ns3136718.ip-51-77-66.eu:8006/   --username=c.assogba@pve   --password="6BzYPqSfd&d8o&vsxV"   --trust-invalid-certs   --list --pretty > "$INVENTORIES"/dynamic/narnia.json


python process.py

