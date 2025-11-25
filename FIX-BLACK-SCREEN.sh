#!/usr/bin/env bash
#
# Emergency Fix for Black Screen / Flickering Cursor Issue
# Run this if Hyprland won't start after installation
#

echo "=========================================="
echo "  ElysiumArch - Black Screen Fix"
echo "=========================================="
echo ""

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root!"
    echo "Usage: sudo ./FIX-BLACK-SCREEN.sh"
    exit 1
fi

# Get username
read -p "Enter your username: " USERNAME

if ! id "$USERNAME" &>/dev/null; then
    echo "ERROR: User $USERNAME does not exist!"
    exit 1
fi

echo "Fixing .profile for user: $USERNAME"
echo ""

# Backup existing .profile
if [ -f /home/$USERNAME/.profile ]; then
    cp /home/$USERNAME/.profile /home/$USERNAME/.profile.backup
    echo "✓ Backed up .profile to .profile.backup"
fi

# Remove problematic LIBGL_ALWAYS_SOFTWARE line
if grep -q "LIBGL_ALWAYS_SOFTWARE" /home/$USERNAME/.profile 2>/dev/null; then
    sed -i '/LIBGL_ALWAYS_SOFTWARE/d' /home/$USERNAME/.profile
    echo "✓ Removed LIBGL_ALWAYS_SOFTWARE (causes black screen)"
fi

# Ensure proper environment variables
cat > /home/$USERNAME/.profile << 'EOF'
# ~/.profile

# Wayland environment variables
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_CURRENT_DESKTOP=Hyprland
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland
export MOZ_ENABLE_WAYLAND=1

# Hyprland stability settings
export HYPRLAND_LOG_WLR=1
export XCURSOR_SIZE=24

# VM-specific settings (if in VM)
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1

# Hyprland autostart is handled by .bash_profile
EOF

chown $USERNAME:$USERNAME /home/$USERNAME/.profile
chmod 644 /home/$USERNAME/.profile

echo "✓ Updated .profile with correct settings"
echo ""
echo "=========================================="
echo "  Fix Applied!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Reboot your system: reboot"
echo "2. Login will happen automatically"
echo "3. Hyprland should start immediately"
echo ""
echo "If Hyprland still doesn't start:"
echo "1. Check logs: journalctl -xe"
echo "2. Check Hyprland log: cat ~/.local/share/hyprland/hyprland.log"
echo "3. Try manually: Hyprland"
echo ""
