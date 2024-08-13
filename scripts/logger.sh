#!/bin/bash

log_action() {
    log_file="$PLAYBOOKS/action_log"
    current_time=$(date '+%Y-%m-%d %H:%M:%S')
    user=$(whoami)
    action=$1

    echo "$current_time | User: $user | Action: $action" >> "$log_file"
}
