#!/usr/bin/env bash
#
# Emergency Fix for Hyprland EGL Initialization Failure
# Run this to fix "ASSERTION FAILED! EGL: failed to initialize" error
#

echo "=========================================="
echo "  ElysiumArch - Hyprland EGL Fix"
echo "=========================================="
echo ""

# Fix the .bash_profile order
cat > ~/.bash_profile << 'BASH_PROFILE'
# ~/.bash_profile

# Source .profile FIRST for environment variables (critical for VM!)
if [ -f ~/.profile ]; then
    . ~/.profile
fi

# Start Hyprland automatically on TTY1
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec Hyprland 2>&1 | tee -a ~/.hyprland-crash.log
fi

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
BASH_PROFILE

# Ensure .profile has VM settings
if ! grep -q "WLR_RENDERER_ALLOW_SOFTWARE" ~/.profile 2>/dev/null; then
    cat >> ~/.profile << 'PROFILE_APPEND'

# VM-specific Hyprland settings (software rendering)
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
PROFILE_APPEND
    echo "✓ Added VM rendering flags to .profile"
else
    echo "✓ VM rendering flags already present in .profile"
fi

echo "✓ Fixed .bash_profile order"
echo ""
echo "=========================================="
echo "  Fix Applied!"
echo "=========================================="
echo ""
echo "IMPORTANT: Verify your .profile has these lines:"
echo "  export WLR_NO_HARDWARE_CURSORS=1"
echo "  export WLR_RENDERER_ALLOW_SOFTWARE=1"
echo ""
echo "Check with: cat ~/.profile"
echo ""
echo "Next steps:"
echo "1. Logout: exit"
echo "2. System will auto-login again"
echo "3. Hyprland should start with software rendering"
echo ""
echo "Or manually test now:"
echo "  source ~/.profile && Hyprland"
echo ""
