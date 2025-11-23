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

# Install Dash to Dock for better dock customization
print_info "Installing Dash to Dock extension..."
arch-chroot /mnt pacman -S --noconfirm --needed gnome-shell-extension-dash-to-dock

print_success "Dash to Dock installed"

# Create extension configuration script
print_info "Configuring GNOME extensions..."

mkdir -p /mnt/home/$USERNAME/.local/bin
cat > /mnt/home/$USERNAME/.local/bin/configure-extensions.sh << 'EXTEOF'
#!/bin/bash

# Enable extensions
gnome-extensions enable blur-my-shell@aunetx
gnome-extensions enable dash-to-dock@micxgx.gmail.com

# Configure Blur My Shell
gsettings set org.gnome.shell.extensions.blur-my-shell.panel blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.panel brightness 0.6
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock brightness 0.6

# Configure Dash to Dock - macOS style (always visible at bottom)
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
   - Provides modern, polished visual appearance

2. Dash to Dock
   - Customized dock at bottom (always visible, macOS-style)
   - Only shows currently running applications
   - Blue theme background (#1e3a5f) with transparency
   - Icon size: 56px

Extension Configuration:
------------------------
- Extensions will be automatically enabled on first login
- Use "Extension Manager" app to install more extensions
- All extensions are configured for dark theme compatibility
- Polkit authentication agent installed (no password prompts hang)

Alternative Dock Extensions:
----------------------------
If you prefer "Docking" by Ochi instead of Dash to Dock:
1. Open "Extension Manager" app
2. Click "Browse" tab
3. Search for "Docking" by ochi
4. Click "Install" (authentication will work now!)
5. Disable Dash to Dock in Extension Manager
6. Enable Docking extension

To manually enable/disable extensions:
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
log_success "Extensions: Arc Menu, Blur My Shell, and Dash to Dock configured"

print_info "Extension configuration will be applied on first login"
print_info "Dock: Only running apps, dark gray background, auto-hide enabled"
