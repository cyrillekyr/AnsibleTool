#! /bin/bash

source config.sh

python3 $INVENTORIES/dynamic/proxmox.py --url=hub.com --username=user --password=pass --trust-invalid-certs --list --pretty > ../inventories/dynamic/mynode.json

python3 $INVENTORIES/dynamic/process.py config.json