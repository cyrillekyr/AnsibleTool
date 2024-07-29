#!/bin/bash

# Define the server to check
SERVER=$1
TIMEOUT=5

# Check if the server is reachable
if ping -c 1 -W $TIMEOUT "$SERVER" > /dev/null 2>&1; then
    echo "Server $SERVER is UP"
else
    echo "Server $SERVER is DOWN"
fi
