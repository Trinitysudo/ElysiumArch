#!/usr/bin/env bash
#
# UI Functions for ElysiumArch Installer
#

# Display menu and get user selection
show_menu() {
    local title="$1"
    shift
    local options=("$@")
    
    echo ""
    echo "══════════════════════════════════════"
    echo "  $title"
    echo "══════════════════════════════════════"
    
    local i=1
    for option in "${options[@]}"; do
        echo "  $i) $option"
        ((i++))
    done
    
    echo ""
    read -p "Select an option [1-$((i-1))]: " choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -lt "$i" ]]; then
        return "$((choice - 1))"
    else
        print_error "Invalid selection"
        return 255
    fi
}

# Display a list and let user select
select_from_list() {
    local title="$1"
    shift
    local items=("$@")
    
    PS3="$title: "
    select item in "${items[@]}"; do
        if [[ -n "$item" ]]; then
            echo "$item"
            return 0
        else
            print_error "Invalid selection"
        fi
    done
}

# Display loading animation
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Display progress with message
show_progress_msg() {
    local message="$1"
    local total_steps="${2:-100}"
    local current_step="${3:-0}"
    
    local percentage=$((current_step * 100 / total_steps))
    printf "\r%-60s [%3d%%]" "$message" "$percentage"
    
    if [[ $current_step -eq $total_steps ]]; then
        echo ""
    fi
}

# Draw a box around text
draw_box() {
    local text="$1"
    local length=${#text}
    local border="$(printf '═%.0s' $(seq 1 $((length + 4))))"
    
    echo "╔${border}╗"
    echo "║  ${text}  ║"
    echo "╚${border}╝"
}

# Export functions
export -f show_menu
export -f select_from_list
export -f show_spinner
export -f show_progress_msg
export -f draw_box
