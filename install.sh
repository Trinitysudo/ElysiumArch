#!/usr/bin/env bash
#
# ElysiumArch - Automated Arch Linux Installer
# Optimized for Java Development with Hyprland
#
# Author: Trinitysudo
# GitHub: https://github.com/Trinitysudo/ElysiumArch
# License: MIT
#

# Note: set -e removed to allow proper error handling in modules

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/logs/install.log"

# Create log file
mkdir -p "${SCRIPT_DIR}/logs"
# Redirect output to log file while preserving stdin
exec 3>&1 4>&2
exec > >(tee -a "$LOG_FILE") 2>&1
# Restore stdin to ensure interactive prompts work
exec 0</dev/tty || exec 0<&1

# Initialize debug log - output to both file and screen
DEBUG_LOG="/tmp/elysium-debug.log"
echo "=========================================" | tee "$DEBUG_LOG"
echo "ElysiumArch Debug Log" | tee -a "$DEBUG_LOG"
echo "Started: $(date)" | tee -a "$DEBUG_LOG"
echo "=========================================" | tee -a "$DEBUG_LOG"

# Trap to catch unexpected exits
trap 'echo "[TRAP] Script exited at line $LINENO with exit code $?" | tee -a "$DEBUG_LOG"' ERR

# Source config file first (user edits this)
if [[ -f "${SCRIPT_DIR}/config.sh" ]]; then
    source "${SCRIPT_DIR}/config.sh"
    export USERNAME USER_PASSWORD ROOT_PASSWORD TIMEZONE LOCALE KEYMAP DISK SKIP_PARU SKIP_HOMEBREW
    print_info "Loaded configuration from config.sh"
fi

# Source helper scripts
source "${SCRIPT_DIR}/scripts/helpers.sh"
source "${SCRIPT_DIR}/scripts/logger.sh"
source "${SCRIPT_DIR}/scripts/ui.sh"
source "${SCRIPT_DIR}/scripts/checkpoint.sh"

# Load saved configuration if resuming (overrides config.sh if exists)
if [[ -f /tmp/elysium-config/user.conf ]]; then
    source /tmp/elysium-config/user.conf
    export USERNAME USER_PASSWORD ROOT_PASSWORD
fi

# Run module with checkpoint
run_module() {
    local module_file="$1"
    local module_name=$(basename "$module_file" .sh)
    
    # Check if module already completed
    if is_module_completed "$module_name"; then
        print_info "Skipping $module_name (already completed)"
        return 0
    fi
    
    # Save checkpoint before running
    save_checkpoint "$module_name"
    
    # Run the module
    source "$module_file"
    
    # Mark as completed if successful
    if [[ $? -eq 0 ]]; then
        mark_module_completed "$module_name"
    else
        print_error "Module $module_name failed!"
        print_info "You can restart the installer to resume from this point"
        exit 1
    fi
}

# Main installation function
main() {
    clear
    
    # Display welcome banner
    print_banner
    
    log_info "ElysiumArch Installation Started at $(date)"
    log_info "=========================================="
    
    # Check for existing installation
    LAST_CHECKPOINT=$(load_checkpoint)
    if [[ "$LAST_CHECKPOINT" != "none" ]]; then
        print_warning "Previous installation detected at: $LAST_CHECKPOINT"
        if confirm "Resume from last checkpoint?"; then
            print_info "Resuming installation..."
        else
            print_info "Starting fresh installation..."
            clear_checkpoints
        fi
    fi
    
    # Debug mode option - FIRST PROMPT (before everything else)
    export DEBUG_MODE=false
    if [[ "$LAST_CHECKPOINT" == "none" ]]; then
        echo ""
        print_info "=========================================="
        print_info "  Debug Mode"
        print_info "=========================================="
        echo ""
        echo "Skip apps/utilities/dev tools for faster testing?"
        echo ""
        if confirm "Enable debug mode?"; then
            export DEBUG_MODE=true
            print_warning "DEBUG MODE ENABLED - Apps will be skipped!"
        else
            print_success "Full installation mode"
        fi
        echo ""
    fi
    
    # Pre-installation checks
    check_system_requirements
    
    # Get user configuration (skip if already set in config.sh or resuming)
    if [[ -z "$USERNAME" || "$USERNAME" == "youruser" ]]; then
        print_warning "USERNAME not configured in config.sh"
        get_user_configuration
    else
        print_success "Using configuration from config.sh (Username: $USERNAME)"
        # Save for resume capability
        mkdir -p /tmp/elysium-config
        cat > /tmp/elysium-config/user.conf << EOF
USERNAME="$USERNAME"
USER_PASSWORD="$USER_PASSWORD"
ROOT_PASSWORD="$ROOT_PASSWORD"
DEBUG_MODE="$DEBUG_MODE"
EOF
    fi
    
    # Confirm installation (skip if resuming and already confirmed)
    if [[ "$LAST_CHECKPOINT" == "none" ]]; then
        echo "[DEBUG] About to call confirm_installation()" | tee -a "$DEBUG_LOG"
        if ! confirm_installation; then
            echo "[ERROR] User cancelled installation at main prompt, exiting" | tee -a "$DEBUG_LOG"
            log_error "Installation cancelled by user"
            exit 0
        fi
        echo "[DEBUG] User confirmed installation, starting Phase 1" | tee -a "$DEBUG_LOG"
    fi
    
    # Phase 1: Pre-Installation (Network, Localization, Disk)
    print_phase "PHASE 1: PRE-INSTALLATION"
    run_module "${SCRIPT_DIR}/modules/01-network.sh"
    run_module "${SCRIPT_DIR}/modules/02-localization.sh"
    run_module "${SCRIPT_DIR}/modules/03-disk.sh"
    
    # Phase 2: Base System Installation
    print_phase "PHASE 2: BASE SYSTEM INSTALLATION"
    run_module "${SCRIPT_DIR}/modules/04-base-system.sh"
    run_module "${SCRIPT_DIR}/modules/05-bootloader.sh"
    
    # Phase 3: Graphics & Desktop Environment
    print_phase "PHASE 3: HYPRLAND (BARE MINIMUM)"
    run_module "${SCRIPT_DIR}/modules/06-gpu-drivers.sh"
    run_module "${SCRIPT_DIR}/modules/07-desktop-environment.sh"
    
    # Skip everything else - no apps, no configs, no themes
    print_info "Skipping: Package managers, apps, utilities, theming, dev tools"
    
    # Installation complete
    print_success "\n=========================================="
    print_success "  ElysiumArch Installation Complete! 🎉"
    print_success "=========================================="
    
    display_summary
    
    # Prompt for reboot
    if confirm_reboot; then
        log_info "Rebooting system..."
        reboot
    else
        print_info "Remember to reboot your system to complete the installation!"
    fi
}

# Display ASCII banner
print_banner() {
    cat << "EOF"
 ███████╗██╗  ██╗   ██╗███████╗██╗██╗   ██╗███╗   ███╗
 ██╔════╝██║  ╚██╗ ██╔╝██╔════╝██║██║   ██║████╗ ████║
 █████╗  ██║   ╚████╔╝ ███████╗██║██║   ██║██╔████╔██║
 ██╔══╝  ██║    ╚██╔╝  ╚════██║██║██║   ██║██║╚██╔╝██║
 ███████╗███████╗██║   ███████║██║╚██████╔╝██║ ╚═╝ ██║
 ╚══════╝╚══════╝╚═╝   ╚══════╝╚═╝ ╚═════╝ ╚═╝     ╚═╝
                                                        
     █████╗ ██████╗  ██████╗██╗  ██╗                  
    ██╔══██╗██╔══██╗██╔════╝██║  ██║                  
    ███████║██████╔╝██║     ███████║                  
    ██╔══██║██╔══██╗██║     ██╔══██║                  
    ██║  ██║██║  ██║╚██████╗██║  ██║                  
    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝                  
                                                        
    Automated Arch Linux Installer v1.0
    Optimized for Java Development & Hyprland
    
    GitHub: github.com/Trinitysudo/ElysiumArch
    
EOF

    sleep 2
}

# Check system requirements
check_system_requirements() {
    print_info "Checking system requirements..."
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root!"
        print_info "Please run: sudo ./install.sh"
        exit 1
    fi
    print_success "✓ Running as root"
    
    # Check if we're in Arch Linux live environment
    if [[ ! -f /etc/arch-release ]]; then
        print_error "This script must be run from Arch Linux installation media!"
        exit 1
    fi
    print_success "✓ Arch Linux environment detected"
    
    # Check if UEFI mode
    if [[ -d /sys/firmware/efi ]]; then
        print_success "✓ UEFI mode detected"
    else
        print_warning "! BIOS/Legacy mode detected"
        print_info "  This installer supports both UEFI and BIOS"
    fi
    
    # Check internet connection
    print_info "Testing internet connection..."
    if ping -c 2 -W 3 archlinux.org &>/dev/null; then
        print_success "✓ Internet connection active"
    else
        print_error "✗ No internet connection!"
        print_info "Internet is REQUIRED for installation."
        print_info "The next module will help you connect to WiFi."
        if ! confirm "Continue anyway?"; then
            exit 1
        fi
    fi
    
    # Check available RAM
    local total_ram=$(free -m | awk '/^Mem:/{print $2}')
    if [[ $total_ram -lt 2048 ]]; then
        print_warning "! Low RAM: ${total_ram}MB (Recommended: 4GB+)"
    else
        print_success "✓ RAM: ${total_ram}MB"
    fi
    
    # Check disk space (need at least 20GB free)
    local free_space=$(df -m / | awk 'NR==2 {print $4}')
    if [[ $free_space -lt 20480 ]]; then
        print_warning "! Limited disk space: ${free_space}MB available"
        print_warning "  Recommended: 30GB+ free space"
    else
        print_success "✓ Disk space: ${free_space}MB available"
    fi
    
    # Check for required tools
    local missing_tools=()
    for tool in pacman curl wget git; do
        if ! command -v "$tool" &>/dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        exit 1
    fi
    print_success "✓ All required tools present"
    
    echo ""
    print_success "System requirements check PASSED ✓"
    echo ""
}

# Confirm installation
# Get user configuration
get_user_configuration() {
    echo ""
    print_info "=========================================="
    print_info "  System Configuration"
    print_info "=========================================="
    echo ""
    
    # Username
    while true; do
        read -p "$(print_info "Enter your username (lowercase, no spaces): ")" USERNAME
        if [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
            break
        else
            print_error "Invalid username. Use lowercase letters, numbers, dash, and underscore only."
        fi
    done
    
    # Single password for both user and root (simplified!)
    print_info "This password will be used for both your user account AND root"
    while true; do
        read -sp "$(print_info "Enter password (any length): ")" USER_PASSWORD
        echo ""
        read -sp "$(print_info "Confirm password: ")" USER_PASSWORD2
        echo ""
        if [[ "$USER_PASSWORD" == "$USER_PASSWORD2" ]]; then
            # Use same password for root
            ROOT_PASSWORD="$USER_PASSWORD"
            break
        else
            print_error "Passwords do not match. Try again."
        fi
    done
    
    # Save configuration for resume
    mkdir -p /tmp/elysium-config
    cat > /tmp/elysium-config/user.conf << EOF
USERNAME="$USERNAME"
USER_PASSWORD="$USER_PASSWORD"
ROOT_PASSWORD="$ROOT_PASSWORD"
EOF
    
    print_success "Configuration saved"
    
    # Export for current session
    export USERNAME USER_PASSWORD ROOT_PASSWORD
}

confirm_installation() {
    echo ""
    print_warning "=========================================="
    print_warning "  IMPORTANT: READ BEFORE PROCEEDING"
    print_warning "=========================================="
    echo ""
    print_info "This installer will:"
    print_info "  • Format and partition your selected disk"
    print_info "  • Install Arch Linux base system"
    print_info "  • Install Hyprland window manager (Wayland)"
    print_info "  • Install development tools (Java, Node.js, etc.)"
    print_info "  • Install applications (Browser, Discord, Steam, etc.)"
    print_info "  • Configure system with blue/black theme"
    echo ""
    print_info "GPU Support:"
    print_info "  • NVIDIA (automatic driver installation)"
    print_info "  • AMD (automatic driver installation)"
    print_info "  • Intel (automatic driver installation)"
    print_info "  • Virtual Machines (VM-optimized drivers)"
    echo ""
    print_info "Features:"
    print_info "  • Smart GPU detection and driver installation"
    print_info "  • First-boot installation report with status"
    print_info "  • Gaming-ready with proper 32-bit library support"
    echo ""
    print_info "Estimated Installation Time: 60-90 minutes"
    print_info "Internet connection is required throughout."
    echo ""
    print_warning "ALL DATA ON THE SELECTED DISK WILL BE ERASED!"
    echo ""
    
    confirm "Do you want to proceed with the installation?"
}

# Display installation summary
display_summary() {
    echo ""
    print_info "=========================================="
    print_info "  Installation Summary"
    print_info "=========================================="
    print_info "✓ Base system installed and configured"
    print_info "✓ Hyprland window manager installed"
    
    # Check GPU drivers installed
    if ! systemd-detect-virt --quiet; then
        if lspci 2>/dev/null | grep -i nvidia &>/dev/null; then
            print_info "✓ NVIDIA GPU drivers installed"
        elif lspci 2>/dev/null | grep -i amd | grep -i vga &>/dev/null; then
            print_info "✓ AMD GPU drivers installed"
        elif lspci 2>/dev/null | grep -i intel | grep -i vga &>/dev/null; then
            print_info "✓ Intel GPU drivers installed"
        else
            print_info "✓ Graphics drivers configured"
        fi
    else
        print_info "✓ VM graphics drivers configured"
    fi
    
    print_info "✓ Development tools installed:"
    print_info "    - Java OpenJDK 17 & 21"
    print_info "    - Visual Studio Code"
    print_info "    - IntelliJ IDEA Community"
    print_info "    - Node.js & npm"
    print_info "✓ Applications installed:"
    print_info "    - Brave Browser"
    print_info "    - Discord"
    print_info "    - Steam"
    print_info "    - OBS Studio"
    print_info "    - And more..."
    print_info "✓ Package managers installed:"
    print_info "    - yay (AUR helper)"
    print_info "    - paru (AUR helper)"
    print_info "    - Homebrew"
    print_info "✓ ML4W Dotfiles installed (Professional Hyprland config)"
    print_info "✓ Waybar, Rofi, and Dunst fully configured"
    print_info "✓ Multi-monitor support ready"
    print_info "✓ Timeshift backup system enabled"
    print_info "✓ Security features configured:"
    print_info "    - UFW Firewall"
    print_info "    - Fail2Ban"
    print_info "    - AppArmor"
    print_info "    - System auditing"
    echo ""
    print_info "Installation log saved to:"
    print_info "  ${LOG_FILE}"
    echo ""
    print_info "Next Steps After Reboot:"
    print_info "  1. System will boot directly to TTY1"
    print_info "  2. Auto-login to your account"
    print_info "  3. Hyprland will start automatically with ML4W config"
    print_info "  4. Update system: yay -Syu"
    print_info "  5. Create first Timeshift snapshot"
    print_info "  6. Customize ML4W dotfiles to your liking"
    echo ""
    print_success "Thank you for using ElysiumArch!"
    echo ""
}

# Confirm reboot
confirm_reboot() {
    echo ""
    confirm "Do you want to reboot now?"
}

# Start installation
main "$@"
