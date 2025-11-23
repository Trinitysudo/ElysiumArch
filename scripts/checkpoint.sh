#!/usr/bin/env bash
#
# Checkpoint System for Resume Capability
#

CHECKPOINT_FILE="/var/log/elysium/checkpoint"
STATE_FILE="/var/log/elysium/install_state"

# Create checkpoint directory
create_checkpoint_dir() {
    mkdir -p /var/log/elysium
}

# Save checkpoint
save_checkpoint() {
    local module_name="$1"
    create_checkpoint_dir
    echo "$module_name" > "$CHECKPOINT_FILE"
    echo "CHECKPOINT: $module_name at $(date)" >> "$STATE_FILE"
}

# Load last checkpoint
load_checkpoint() {
    if [[ -f "$CHECKPOINT_FILE" ]]; then
        cat "$CHECKPOINT_FILE"
    else
        echo "none"
    fi
}

# Check if module was completed
is_module_completed() {
    local module_name="$1"
    if [[ -f "$STATE_FILE" ]]; then
        grep -q "COMPLETED: $module_name" "$STATE_FILE"
        return $?
    fi
    return 1
}

# Mark module as completed
mark_module_completed() {
    local module_name="$1"
    create_checkpoint_dir
    echo "COMPLETED: $module_name at $(date)" >> "$STATE_FILE"
}

# Get list of completed modules
get_completed_modules() {
    if [[ -f "$STATE_FILE" ]]; then
        grep "COMPLETED:" "$STATE_FILE" | awk '{print $2}'
    fi
}

# Clear checkpoints (for fresh install)
clear_checkpoints() {
    rm -f "$CHECKPOINT_FILE" "$STATE_FILE"
}
