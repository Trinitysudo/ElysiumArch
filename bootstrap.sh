#!/usr/bin/env bash
#
# ElysiumArch Bootstrap Script
# Run this first on a fresh Arch Linux ISO
#

set -e

echo "=========================================="
echo "  ElysiumArch Bootstrap"
echo "=========================================="
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root!"
    echo "   Try: sudo bash bootstrap.sh"
    exit 1
fi

# Check internet connection
echo "🔍 Checking internet connection..."
if ping -c 1 archlinux.org &>/dev/null; then
    echo "✅ Internet connection detected"
else
    echo "❌ No internet connection!"
    echo ""
    echo "Please connect to the internet first:"
    echo ""
    echo "For WiFi:"
    echo "  iwctl"
    echo "  station wlan0 scan"
    echo "  station wlan0 get-networks"
    echo "  station wlan0 connect YOUR_SSID"
    echo "  exit"
    echo ""
    echo "For Ethernet:"
    echo "  dhcpcd"
    echo ""
    echo "Then run this script again."
    exit 1
fi

# Update system clock
echo "🕐 Syncing system clock..."
timedatectl set-ntp true

# Install required tools if not present
echo "📦 Installing required tools..."

# Check and install git
if ! command -v git &>/dev/null; then
    echo "   Installing git..."
    pacman -Sy --noconfirm git
fi

# Check and install curl
if ! command -v curl &>/dev/null; then
    echo "   Installing curl..."
    pacman -S --noconfirm curl
fi

# Check and install wget
if ! command -v wget &>/dev/null; then
    echo "   Installing wget..."
    pacman -S --noconfirm wget
fi

echo "✅ All required tools installed"
echo ""

# Download or clone ElysiumArch
echo "📥 Downloading ElysiumArch installer..."
echo ""
echo "Choose download method:"
echo "1) Git clone (recommended)"
echo "2) Download tarball"
echo ""
read -p "Select [1-2] (default: 1): " method
method=${method:-1}

cd /root

if [[ $method == 1 ]]; then
    echo "📦 Cloning from GitHub..."
    if [[ -d "ElysiumArch" ]]; then
        echo "⚠️  ElysiumArch directory already exists"
        read -p "Remove and re-clone? [y/N]: " response
        if [[ "$response" =~ ^[yY]$ ]]; then
            rm -rf ElysiumArch
            git clone https://github.com/Trinitysudo/ElysiumArch.git
        fi
    else
        git clone https://github.com/Trinitysudo/ElysiumArch.git
    fi
    cd ElysiumArch
else
    echo "📦 Downloading tarball..."
    curl -L https://github.com/Trinitysudo/ElysiumArch/archive/main.tar.gz | tar xz
    cd ElysiumArch-main
fi

echo "✅ ElysiumArch downloaded successfully"
echo ""

# Make installer executable
chmod +x install.sh

# Display info
echo "=========================================="
echo "  Bootstrap Complete! 🎉"
echo "=========================================="
echo ""
echo "You can now run the installer:"
echo ""
echo "  ./install.sh"
echo ""
echo "Or to review first:"
echo "  ls -la"
echo "  cat README.md"
echo ""
echo "⚠️  WARNING: The installer will format your disk!"
echo "   Make sure you have backups of any important data."
echo ""

# Ask if user wants to run installer now
read -p "Run the installer now? [y/N]: " run_now
if [[ "$run_now" =~ ^[yY]$ ]]; then
    echo ""
    echo "Starting ElysiumArch installer..."
    sleep 2
    ./install.sh
else
    echo "Run './install.sh' when ready."
fi
