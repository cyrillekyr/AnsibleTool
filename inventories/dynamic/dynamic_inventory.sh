#! /bin/bash

python3 proxmox.py --url=hub.com --username=user --password=pass --trust-invalid-certs --list --pretty > ../inventories/dynamic/mynode.json

python3 process.py
