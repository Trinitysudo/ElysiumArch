#!/usr/bin/env bash
#
# ElysiumArch Configuration
# Set your preferences here before running install.sh
#

# User Configuration
USERNAME="youruser"           # Your username (lowercase, no spaces)
USER_PASSWORD="yourpassword"  # Your user password (any length)
ROOT_PASSWORD="rootpassword"  # Root password (any length)

# System Configuration
TIMEZONE="America/New_York"   # Your timezone (use: timedatectl list-timezones)
LOCALE="en_US.UTF-8"          # Your locale
KEYMAP="us"                   # Keyboard layout

# Disk Configuration (optional - will prompt if not set)
DISK=""                       # Leave empty to prompt, or set to /dev/sda, /dev/nvme0n1, etc.

# Skip optional components (set to 1 to skip)
SKIP_PARU=0                   # Skip paru installation (0=install, 1=skip)
SKIP_HOMEBREW=0               # Skip Homebrew installation (0=install, 1=skip)
