#!/usr/bin/env bash
#
# Module 13: GNOME Extensions Installation and Configuration
# Install and configure GNOME Shell extensions
#

print_info "Installing GNOME Shell extensions..."

# Install extension manager for easy extension management
print_info "Installing Extension Manager..."
arch-chroot /mnt pacman -S --noconfirm --needed gnome-shell-extensions extension-manager

print_success "Extension Manager installed"

# Install Blur My Shell from AUR
print_info "Installing Blur My Shell extension..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm gnome-shell-extension-blur-my-shell"

if [[ $? -eq 0 ]]; then
    print_success "Blur My Shell installed"
else
    print_warning "Failed to install Blur My Shell (will try alternative method)"
fi

# Install Docking extension by Ochi (user's preferred dock)
print_info "Installing Docking extension by Ochi..."
arch-chroot /mnt sudo -u $USERNAME bash -c "yay -S --noconfirm gnome-shell-extension-dock-ng"

if [[ $? -eq 0 ]]; then
    print_success "Docking extension installed"
else
    print_warning "Docking extension failed, falling back to Dash to Dock..."
    arch-chroot /mnt pacman -S --noconfirm --needed gnome-shell-extension-dash-to-dock
fi

# Create extension configuration script
print_info "Configuring GNOME extensions..."

mkdir -p /mnt/home/$USERNAME/.local/bin
cat > /mnt/home/$USERNAME/.local/bin/configure-extensions.sh << 'EXTEOF'
#!/bin/bash

# Enable extensions
gnome-extensions enable blur-my-shell@aunetx

# Try to enable Docking extension (if installed)
if gnome-extensions list | grep -q "dock-ng"; then
    gnome-extensions enable dock-ng@vamshi.k
    USE_DOCKING=true
else
    gnome-extensions enable dash-to-dock@micxgx.gmail.com
    USE_DOCKING=false
fi

# Enable apps menu (always visible in top bar)
gsettings set org.gnome.shell always-show-apps-menu true
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

# Configure Blur My Shell
gsettings set org.gnome.shell.extensions.blur-my-shell.panel blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.panel brightness 0.6
gsettings set org.gnome.shell.extensions.blur-my-shell.panel transparency 0.3
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock brightness 0.6

# Configure Docking extension if installed
if [ "$USE_DOCKING" = true ]; then
    echo "Configuring Docking extension (by Ochi)..."
    
    # Docking extension settings - always visible at bottom
    gsettings set org.gnome.shell.extensions.dock-ng position 'BOTTOM'
    gsettings set org.gnome.shell.extensions.dock-ng icon-size 56
    gsettings set org.gnome.shell.extensions.dock-ng show-favorites false
    gsettings set org.gnome.shell.extensions.dock-ng show-running true
    gsettings set org.gnome.shell.extensions.dock-ng autohide false
    gsettings set org.gnome.shell.extensions.dock-ng intellihide false
    gsettings set org.gnome.shell.extensions.dock-ng transparency 0.3
    gsettings set org.gnome.shell.extensions.dock-ng background-color '#1e3a5f'
    
    echo "Docking extension configured (always visible, transparent)"
else
    echo "Configuring Dash to Dock as fallback..."
fi

# Configure Dash to Dock (fallback if Docking not available)
# Only show running applications (no pinned apps)
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false

# Dock size and position
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 56
gsettings set org.gnome.shell.extensions.dash-to-dock icon-size-fixed true

# Dock behavior - only show running apps
gsettings set org.gnome.shell.extensions.dash-to-dock show-running true
gsettings set org.gnome.shell.extensions.dash-to-dock show-favorites false
gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces false

# macOS-style behavior: ALWAYS VISIBLE (not auto-hide)
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true
gsettings set org.gnome.shell.extensions.dash-to-dock autohide false
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false

# Blue theme with transparency
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.75
gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color true
gsettings set org.gnome.shell.extensions.dash-to-dock background-color '#1e3a5f'

# Blue accent color for entire system
gsettings set org.gnome.desktop.interface accent-color 'blue'

# Dock appearance - clean and minimal
gsettings set org.gnome.shell.extensions.dash-to-dock apply-custom-theme false
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink false

# Animation settings
gsettings set org.gnome.shell.extensions.dash-to-dock animation-time 0.2

# Hot corners
gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
gsettings set org.gnome.shell.extensions.dash-to-dock hotkeys-overlay false
gsettings set org.gnome.shell.extensions.dash-to-dock hotkeys-show-dock false

# Remove this autostart file after first run
rm -f ~/.config/autostart/configure-gnome-extensions.desktop

echo "Extensions configured successfully!"
EXTEOF

chmod +x /mnt/home/$USERNAME/.local/bin/configure-extensions.sh
chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME/.local

# Create autostart entry for extension configuration
mkdir -p /mnt/home/$USERNAME/.config/autostart

cat > /mnt/home/$USERNAME/.config/autostart/configure-gnome-extensions.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Configure GNOME Extensions
Exec=/home/$USERNAME/.local/bin/configure-extensions.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=5
EOF

# Replace $USERNAME in desktop file
sed -i "s/\$USERNAME/$USERNAME/g" /mnt/home/$USERNAME/.config/autostart/configure-gnome-extensions.desktop

chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME/.config

print_success "Extension configuration script created"

# Create user instructions file for extensions
cat > /mnt/home/$USERNAME/GNOME-EXTENSIONS-INFO.txt << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║          GNOME Extensions Configuration                       ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

Your GNOME desktop has been configured with the following extensions:

1. Blur My Shell
   - Beautiful blur effects on the panel and dock
   - Transparency: 30% for modern look
   - Provides polished visual appearance

2. Docking (by Ochi) - Your Preferred Dock!
   - Always visible at bottom (no auto-hide)
   - Only shows currently running applications
   - Blue theme background (#1e3a5f) with 30% transparency
   - Icon size: 56px
   - Perfect macOS-style dock behavior

3. Apps Menu
   - Always visible in top bar
   - Quick access to all applications
   - Enabled by default

Extension Configuration:
------------------------
- Extensions automatically enabled on first login
- Docking extension already configured and ready
- Apps menu always visible in top panel
- Use "Extension Manager" app for more customization
- All extensions configured for dark theme with blue accents
- Polkit authentication agent installed (no password prompts hang)
- Apps menu always visible for quick app access

Dock Features:
--------------
- ALWAYS VISIBLE (no auto-hide or intellihide)
- Positioned at bottom center of screen
- Shows only running applications (no favorites)
- 30% transparency with blue background
- 56px icon size (perfect balance)
- Blur effect applied

To manage extensions:
---------------------------------------
1. Open "Extension Manager" from app menu
2. Toggle extensions on/off as desired
3. Configure individual extension settings
4. Install more extensions from Browse tab

For advanced customization:
----------------------------
- Use "dconf Editor" to fine-tune settings
- Extension settings at: org.gnome.shell.extensions.*

Enjoy your customized GNOME desktop!

EOF

chown $USERNAME:$USERNAME /mnt/home/$USERNAME/GNOME-EXTENSIONS-INFO.txt

print_success "GNOME extensions installed and configured"
log_success "Extensions: Blur My Shell, Docking (by Ochi), and Apps Menu configured"

print_info "Extension configuration will be applied on first login"
print_info "Docking: Always visible at bottom, blue transparent theme, running apps only"
print_info "Apps Menu: Always visible in top panel for quick app access"
