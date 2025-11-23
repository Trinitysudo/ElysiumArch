#!/usr/bin/env bash
#
# ElysiumArch First Boot Report
# Displays installation summary, errors, and system information
#

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

clear

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                               ║${NC}"
echo -e "${CYAN}║${BOLD}          ElysiumArch Installation Report${NC}${CYAN}                    ║${NC}"
echo -e "${CYAN}║                                                               ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if installation status file exists
if [[ ! -f /tmp/install_status ]]; then
    echo -e "${YELLOW}⚠ Warning: Installation status file not found${NC}"
    echo -e "${YELLOW}This may be a fresh boot without full installation tracking.${NC}"
    echo ""
fi

# System Information
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  SYSTEM INFORMATION${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Hostname
echo -e "${BLUE}Hostname:${NC} $(hostname)"

# Kernel
echo -e "${BLUE}Kernel:${NC} $(uname -r)"

# CPU
CPU_INFO=$(lscpu | grep "Model name" | cut -d: -f2 | xargs)
echo -e "${BLUE}CPU:${NC} $CPU_INFO"

# RAM
RAM_TOTAL=$(free -h | awk '/^Mem:/{print $2}')
echo -e "${BLUE}RAM:${NC} $RAM_TOTAL"

# GPU Detection
echo -e "${BLUE}GPU:${NC}"
if lspci | grep -i nvidia | grep -i vga &>/dev/null; then
    GPU_NAME=$(lspci | grep -i nvidia | grep -i vga | cut -d: -f3 | xargs)
    echo -e "  ${GREEN}✓${NC} NVIDIA: $GPU_NAME"
fi
if lspci | grep -i amd | grep -i vga &>/dev/null; then
    GPU_NAME=$(lspci | grep -i amd | grep -i vga | cut -d: -f3 | xargs)
    echo -e "  ${GREEN}✓${NC} AMD: $GPU_NAME"
fi
if lspci | grep -i intel | grep -i vga &>/dev/null; then
    GPU_NAME=$(lspci | grep -i intel | grep -i vga | cut -d: -f3 | xargs)
    echo -e "  ${GREEN}✓${NC} Intel: $GPU_NAME"
fi

# Virtualization
if systemd-detect-virt --quiet; then
    VIRT_TYPE=$(systemd-detect-virt)
    echo -e "${BLUE}Virtualization:${NC} ${YELLOW}$VIRT_TYPE${NC}"
else
    echo -e "${BLUE}Virtualization:${NC} ${GREEN}Bare Metal${NC}"
fi

echo ""

# Installation Status
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  INSTALLATION STATUS${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Track success and failure counts
SUCCESS_COUNT=0
FAILURE_COUNT=0
WARNING_COUNT=0

# Function to check and display status
check_component() {
    local component=$1
    local check_command=$2
    local name=$3
    
    if eval "$check_command" &>/dev/null; then
        echo -e "${GREEN}✓${NC} $name"
        ((SUCCESS_COUNT++))
        return 0
    else
        echo -e "${RED}✗${NC} $name"
        ((FAILURE_COUNT++))
        return 1
    fi
}

# Core System Components
echo -e "${BOLD}Core System:${NC}"
check_component "bootloader" "command -v grub-mkconfig" "GRUB Bootloader"
check_component "network" "systemctl is-enabled NetworkManager" "NetworkManager"
check_component "audio" "systemctl --user is-active pipewire" "PipeWire Audio" || ((WARNING_COUNT++))
check_component "bluetooth" "systemctl is-enabled bluetooth" "Bluetooth Service"
echo ""

# Desktop Environment
echo -e "${BOLD}Desktop Environment:${NC}"
check_component "gnome" "command -v gnome-shell" "GNOME Shell"
check_component "gdm" "systemctl is-enabled gdm" "GDM Display Manager"
check_component "extensions" "command -v gnome-extensions" "GNOME Extensions"
echo ""

# GPU Drivers
echo -e "${BOLD}Graphics Drivers:${NC}"
if [[ -f /tmp/gpu_type ]]; then
    GPU_TYPE=$(cat /tmp/gpu_type)
    case $GPU_TYPE in
        NVIDIA)
            if check_component "nvidia" "command -v nvidia-smi" "NVIDIA Drivers"; then
                NVIDIA_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo "Unknown")
                echo -e "  ${CYAN}Version:${NC} $NVIDIA_VERSION"
            fi
            ;;
        AMD)
            check_component "amdgpu" "lsmod | grep amdgpu" "AMD GPU Drivers"
            check_component "vulkan_amd" "command -v vulkaninfo" "Vulkan Support"
            ;;
        INTEL)
            check_component "i915" "lsmod | grep i915" "Intel GPU Drivers"
            ;;
        VM)
            echo -e "${YELLOW}⚠${NC} VM Generic Drivers (Expected)"
            ((WARNING_COUNT++))
            ;;
    esac
else
    echo -e "${YELLOW}⚠${NC} GPU type not recorded"
    ((WARNING_COUNT++))
fi
echo ""

# Package Managers
echo -e "${BOLD}Package Managers:${NC}"
check_component "pacman" "command -v pacman" "Pacman"
check_component "yay" "command -v yay" "Yay (AUR Helper)"
check_component "paru" "command -v paru" "Paru (AUR Helper)" || ((WARNING_COUNT++))
if check_component "brew" "command -v brew" "Homebrew"; then
    :
else
    ((WARNING_COUNT++))
fi
echo ""

# Development Tools
echo -e "${BOLD}Development Tools:${NC}"
check_component "java" "command -v java" "Java JDK"
if command -v java &>/dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d\" -f2)
    echo -e "  ${CYAN}Version:${NC} $JAVA_VERSION"
fi
check_component "node" "command -v node" "Node.js"
if command -v node &>/dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "  ${CYAN}Version:${NC} $NODE_VERSION"
fi
check_component "python" "command -v python" "Python"
check_component "git" "command -v git" "Git"
echo ""

# Applications
echo -e "${BOLD}Applications:${NC}"
check_component "vscode" "command -v code" "Visual Studio Code" || ((WARNING_COUNT++))
check_component "idea" "command -v idea" "IntelliJ IDEA" || ((WARNING_COUNT++))
check_component "brave" "command -v brave" "Brave Browser" || ((WARNING_COUNT++))
check_component "discord" "command -v discord" "Discord" || ((WARNING_COUNT++))
check_component "steam" "command -v steam" "Steam" || ((WARNING_COUNT++))
echo ""

# System Utilities
echo -e "${BOLD}System Utilities:${NC}"
check_component "kitty" "command -v kitty" "Kitty Terminal" || ((WARNING_COUNT++))
check_component "timeshift" "command -v timeshift" "Timeshift Backup" || ((WARNING_COUNT++))
check_component "fastfetch" "command -v fastfetch" "Fastfetch" || ((WARNING_COUNT++))
echo ""

# Security
echo -e "${BOLD}Security:${NC}"
check_component "ufw" "command -v ufw" "UFW Firewall"
check_component "fail2ban" "systemctl is-enabled fail2ban" "Fail2Ban" || ((WARNING_COUNT++))
check_component "apparmor" "systemctl is-enabled apparmor" "AppArmor" || ((WARNING_COUNT++))
echo ""

# Check for errors in installation log
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  INSTALLATION LOG ANALYSIS${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check for specific errors in status file
if [[ -f /tmp/install_status ]]; then
    if grep -q "FAILED" /tmp/install_status; then
        echo -e "${RED}✗ Some components failed to install:${NC}"
        grep "FAILED" /tmp/install_status | while read line; do
            echo -e "  ${RED}•${NC} $line"
        done
        echo ""
    fi
fi

# Summary
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  SUMMARY${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

TOTAL=$((SUCCESS_COUNT + FAILURE_COUNT))
if [[ $TOTAL -gt 0 ]]; then
    SUCCESS_PERCENT=$((SUCCESS_COUNT * 100 / TOTAL))
else
    SUCCESS_PERCENT=0
fi

echo -e "${GREEN}✓ Successful:${NC} $SUCCESS_COUNT components"
if [[ $FAILURE_COUNT -gt 0 ]]; then
    echo -e "${RED}✗ Failed:${NC} $FAILURE_COUNT components"
fi
if [[ $WARNING_COUNT -gt 0 ]]; then
    echo -e "${YELLOW}⚠ Warnings:${NC} $WARNING_COUNT components (optional)"
fi
echo -e "${CYAN}Overall Success Rate:${NC} ${SUCCESS_PERCENT}%"
echo ""

# Overall Status
if [[ $FAILURE_COUNT -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║                                                               ║${NC}"
    echo -e "${GREEN}${BOLD}║  ✓ INSTALLATION SUCCESSFUL!                                   ║${NC}"
    echo -e "${GREEN}${BOLD}║                                                               ║${NC}"
    echo -e "${GREEN}${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
elif [[ $FAILURE_COUNT -le 3 ]]; then
    echo -e "${YELLOW}${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}${BOLD}║                                                               ║${NC}"
    echo -e "${YELLOW}${BOLD}║  ⚠ INSTALLATION COMPLETED WITH MINOR ISSUES                   ║${NC}"
    echo -e "${YELLOW}${BOLD}║                                                               ║${NC}"
    echo -e "${YELLOW}${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
else
    echo -e "${RED}${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}${BOLD}║                                                               ║${NC}"
    echo -e "${RED}${BOLD}║  ✗ INSTALLATION COMPLETED WITH ERRORS                         ║${NC}"
    echo -e "${RED}${BOLD}║                                                               ║${NC}"
    echo -e "${RED}${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
fi
echo ""

# Next Steps
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  NEXT STEPS${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}1.${NC} Update your system:"
echo -e "   ${CYAN}yay -Syu${NC}"
echo ""
echo -e "${BLUE}2.${NC} Create your first backup snapshot:"
echo -e "   ${CYAN}sudo timeshift --create --comments \"Fresh Install\"${NC}"
echo ""
echo -e "${BLUE}3.${NC} Enable the firewall (if needed):"
echo -e "   ${CYAN}sudo ufw enable${NC}"
echo ""
echo -e "${BLUE}4.${NC} Test your GPU (if NVIDIA):"
echo -e "   ${CYAN}nvidia-smi${NC}"
echo ""
echo -e "${BLUE}5.${NC} View full installation log:"
echo -e "   ${CYAN}less ~/elysium-install.log${NC}"
echo ""

# Option to view detailed logs
echo -e "${YELLOW}Press any key to close this window...${NC}"
read -n 1 -s

# Self-destruct - remove this script after first run
rm -f ~/.config/autostart/elysium-first-boot-report.desktop
rm -f ~/.local/bin/elysium-report.sh
