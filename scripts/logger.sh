#!/usr/bin/env bash
#
# Logger Functions for ElysiumArch Installer
#

LOG_FILE="${SCRIPT_DIR}/logs/install.log"

# Initialize log file
init_logger() {
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "=========================================" >> "$LOG_FILE"
    echo "ElysiumArch Installation Log" >> "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "=========================================" >> "$LOG_FILE"
}

# Log info message
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "$LOG_FILE"
}

# Log success message
log_success() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $1" >> "$LOG_FILE"
}

# Log error message
log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> "$LOG_FILE"
}

# Log warning message
log_warning() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] $1" >> "$LOG_FILE"
}

# Log command execution
log_command() {
    local cmd="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [COMMAND] $cmd" >> "$LOG_FILE"
}

# Export functions
export -f log_info
export -f log_success
export -f log_error
export -f log_warning
export -f log_command
