#!/usr/bin/env bash
#
# Helper Functions for ElysiumArch Installer
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_phase() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  $1"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
}

# Confirmation prompt
confirm() {
    local prompt="$1"
    local response
    
    echo "[DEBUG] confirm() called with: '$prompt'" | tee -a /tmp/elysium-debug.log
    echo "[DEBUG] Checking stdin: $(test -t 0 && echo 'interactive' || echo 'non-interactive')" | tee -a /tmp/elysium-debug.log
    
    while true; do
        read -r -p "$(echo -e ${YELLOW}[?]${NC}) $prompt [y/N]: " response
        local read_exit_code=$?
        echo "[DEBUG] read command exit code: $read_exit_code" | tee -a /tmp/elysium-debug.log
        echo "[DEBUG] User response: '$response'" | tee -a /tmp/elysium-debug.log
        
        # Check if read failed (EOF or error)
        if [[ $read_exit_code -ne 0 ]]; then
            echo "[ERROR] read command failed with exit code $read_exit_code - stdin may not be interactive" | tee -a /tmp/elysium-debug.log
            return 1
        fi
        
        case "$response" in
            [yY][eE][sS]|[yY]) 
                echo "[DEBUG] Returning 0 (yes)" | tee -a /tmp/elysium-debug.log
                return 0
                ;;
            [nN][oO]|[nN])
                echo "[DEBUG] Returning 1 (no/cancel)" | tee -a /tmp/elysium-debug.log
                return 1
                ;;
            "")
                echo "[DEBUG] Empty input, looping again" | tee -a /tmp/elysium-debug.log
                print_error "Please answer yes or no."
                ;;
            *)
                echo "[DEBUG] Invalid input '$response', looping again" | tee -a /tmp/elysium-debug.log
                print_error "Please answer yes or no."
                echo "[DEBUG] About to loop again in confirm function" | tee -a /tmp/elysium-debug.log
                ;;
        esac
    done
    echo "[DEBUG] Exited confirm while loop - THIS SHOULD NEVER HAPPEN" | tee -a /tmp/elysium-debug.log
}

# Install packages using pacman
install_packages() {
    local packages=("$@")
    print_info "Installing packages: ${packages[*]}"
    
    if pacman -S --noconfirm --needed "${packages[@]}"; then
        print_success "Packages installed successfully"
        return 0
    else
        print_error "Failed to install packages"
        return 1
    fi
}

# Install packages using yay (AUR)
install_aur_packages() {
    local packages=("$@")
    local username="$INSTALL_USER"
    
    print_info "Installing AUR packages: ${packages[*]}"
    
    if sudo -u "$username" yay -S --noconfirm --needed "${packages[@]}"; then
        print_success "AUR packages installed successfully"
        return 0
    else
        print_error "Failed to install AUR packages"
        return 1
    fi
}

# Install packages from a file
install_from_file() {
    local file="$1"
    local use_aur="${2:-false}"
    
    if [[ ! -f "$file" ]]; then
        print_error "Package file not found: $file"
        return 1
    fi
    
    # Read packages from file (skip comments and empty lines)
    local packages=()
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        packages+=("$line")
    done < "$file"
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        print_warning "No packages found in $file"
        return 0
    fi
    
    if [[ "$use_aur" == "true" ]]; then
        install_aur_packages "${packages[@]}"
    else
        install_packages "${packages[@]}"
    fi
}

# Enable systemd service
enable_service() {
    local service="$1"
    print_info "Enabling service: $service"
    
    if systemctl enable "$service"; then
        print_success "Service enabled: $service"
        return 0
    else
        print_error "Failed to enable service: $service"
        return 1
    fi
}

# Start systemd service
start_service() {
    local service="$1"
    print_info "Starting service: $service"
    
    if systemctl start "$service"; then
        print_success "Service started: $service"
        return 0
    else
        print_error "Failed to start service: $service"
        return 1
    fi
}

# Copy configuration file
copy_config() {
    local src="$1"
    local dest="$2"
    local owner="${3:-root:root}"
    
    print_info "Copying config: $(basename $src) -> $dest"
    
    if cp "$src" "$dest"; then
        chown "$owner" "$dest"
        print_success "Config copied successfully"
        return 0
    else
        print_error "Failed to copy config"
        return 1
    fi
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    local owner="${2:-root:root}"
    
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        chown "$owner" "$dir"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Wait for user input
pause() {
    read -p "Press [Enter] to continue..."
}

# Show progress bar
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\r["
    printf "%${completed}s" | tr ' ' '='
    printf "%${remaining}s" | tr ' ' '-'
    printf "] %d%%" "$percentage"
}

# Run command in chroot
arch_chroot() {
    arch-chroot /mnt /bin/bash -c "$1"
}

# Export functions
export -f print_info
export -f print_success
export -f print_error
export -f print_warning
export -f print_phase
export -f confirm
export -f install_packages
export -f install_aur_packages
export -f install_from_file
export -f enable_service
export -f start_service
export -f copy_config
export -f ensure_dir
export -f command_exists
export -f pause
export -f show_progress
export -f arch_chroot
