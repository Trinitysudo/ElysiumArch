#!/usr/bin/env bash
#
# Pre-Flight Checklist - Run this before installation
# Validates that everything is ready for ElysiumArch installation
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  ElysiumArch Pre-Flight Checklist${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

ERRORS=0
WARNINGS=0

# Check 1: Running as root
echo -n "Checking root privileges... "
if [[ $EUID -eq 0 ]]; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
    echo -e "  ${RED}Must run as root: sudo ./preflight-check.sh${NC}"
    ((ERRORS++))
fi

# Check 2: Arch Linux environment
echo -n "Checking Arch Linux environment... "
if [[ -f /etc/arch-release ]]; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
    echo -e "  ${RED}Must run from Arch Linux ISO${NC}"
    ((ERRORS++))
fi

# Check 3: Boot mode (UEFI/BIOS)
echo -n "Checking boot mode... "
if [[ -d /sys/firmware/efi ]]; then
    echo -e "${GREEN}✓ UEFI${NC}"
else
    echo -e "${YELLOW}! BIOS/Legacy${NC}"
    echo -e "  ${YELLOW}UEFI recommended but BIOS supported${NC}"
    ((WARNINGS++))
fi

# Check 4: Internet connection
echo -n "Checking internet connection... "
if ping -c 2 -W 3 archlinux.org &>/dev/null; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
    echo -e "  ${RED}No internet! Connect with: iwctl${NC}"
    ((ERRORS++))
fi

# Check 5: System time
echo -n "Checking system time... "
timedatectl set-ntp true &>/dev/null
if timedatectl status | grep -q "synchronized: yes"; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${YELLOW}! WARNING${NC}"
    echo -e "  ${YELLOW}Time may not be synchronized${NC}"
    ((WARNINGS++))
fi

# Check 6: Available RAM
echo -n "Checking RAM... "
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
if [[ $TOTAL_RAM -ge 4096 ]]; then
    echo -e "${GREEN}✓ ${TOTAL_RAM}MB${NC}"
elif [[ $TOTAL_RAM -ge 2048 ]]; then
    echo -e "${YELLOW}! ${TOTAL_RAM}MB (4GB+ recommended)${NC}"
    ((WARNINGS++))
else
    echo -e "${RED}✗ ${TOTAL_RAM}MB (too low)${NC}"
    echo -e "  ${RED}Minimum 2GB RAM required${NC}"
    ((ERRORS++))
fi

# Check 7: Disk space
echo -n "Checking disk space... "
FREE_SPACE=$(df -m / | awk 'NR==2 {print $4}')
if [[ $FREE_SPACE -ge 30720 ]]; then
    echo -e "${GREEN}✓ ${FREE_SPACE}MB free${NC}"
elif [[ $FREE_SPACE -ge 20480 ]]; then
    echo -e "${YELLOW}! ${FREE_SPACE}MB free (30GB+ recommended)${NC}"
    ((WARNINGS++))
else
    echo -e "${RED}✗ ${FREE_SPACE}MB free (too low)${NC}"
    echo -e "  ${RED}Minimum 20GB free space required${NC}"
    ((ERRORS++))
fi

# Check 8: Required tools
echo -n "Checking required tools... "
MISSING_TOOLS=()
for tool in pacman curl wget git unzip; do
    if ! command -v "$tool" &>/dev/null; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [[ ${#MISSING_TOOLS[@]} -eq 0 ]]; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
    echo -e "  ${RED}Missing: ${MISSING_TOOLS[*]}${NC}"
    ((ERRORS++))
fi

# Check 9: Available disks
echo -n "Checking available disks... "
DISK_COUNT=$(lsblk -d -o NAME -n | grep -cE "^(sd|nvme|vd)")
if [[ $DISK_COUNT -gt 0 ]]; then
    echo -e "${GREEN}✓ $DISK_COUNT disk(s) found${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
    echo -e "  ${RED}No disks detected!${NC}"
    ((ERRORS++))
fi

# Check 10: GPU detection
echo -n "Checking GPU... "
if lspci | grep -i nvidia | grep -i vga &>/dev/null; then
    echo -e "${GREEN}✓ NVIDIA GPU detected${NC}"
elif lspci | grep -i amd | grep -i vga &>/dev/null; then
    echo -e "${GREEN}✓ AMD GPU detected${NC}"
elif lspci | grep -i intel | grep -i vga &>/dev/null; then
    echo -e "${GREEN}✓ Intel GPU detected${NC}"
elif systemd-detect-virt --quiet; then
    VM_TYPE=$(systemd-detect-virt)
    echo -e "${GREEN}✓ VM detected ($VM_TYPE)${NC}"
else
    echo -e "${YELLOW}! Generic graphics${NC}"
    ((WARNINGS++))
fi

# Summary
echo ""
echo -e "${BLUE}========================================${NC}"
if [[ $ERRORS -eq 0 ]]; then
    echo -e "${GREEN}✓ PRE-FLIGHT CHECK PASSED${NC}"
    echo -e "${GREEN}  You are READY to install!${NC}"
    if [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}  $WARNINGS warning(s) - installation will proceed${NC}"
    fi
    echo ""
    echo -e "Run installation with:"
    echo -e "  ${BLUE}./install.sh${NC}"
else
    echo -e "${RED}✗ PRE-FLIGHT CHECK FAILED${NC}"
    echo -e "${RED}  $ERRORS error(s) must be fixed${NC}"
    if [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}  $WARNINGS warning(s)${NC}"
    fi
    echo ""
    echo -e "Fix errors above before proceeding"
    exit 1
fi
echo -e "${BLUE}========================================${NC}"
echo ""

exit 0
