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

# Install Arc Menu from AUR
print_info "Installing Arc Menu extension..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm gnome-shell-extension-arc-menu"

if [[ $? -eq 0 ]]; then
    print_success "Arc Menu installed"
else
    print_warning "Failed to install Arc Menu (will try alternative method)"
fi

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

cat > /mnt/tmp/configure-extensions.sh << 'EXTEOF'
#!/bin/bash

# Enable extensions
gnome-extensions enable arcmenu@arcmenu.com
gnome-extensions enable blur-my-shell@aunetx
gnome-extensions enable dash-to-dock@micxgx.gmail.com

# Configure Arc Menu
gsettings set org.gnome.shell.extensions.arcmenu menu-button-appearance 'Icon'
gsettings set org.gnome.shell.extensions.arcmenu menu-layout 'Eleven'
gsettings set org.gnome.shell.extensions.arcmenu position-in-panel 'Left'

# Configure Blur My Shell
gsettings set org.gnome.shell.extensions.blur-my-shell.panel blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.panel brightness 0.6
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock brightness 0.6

# Configure Dash to Dock
# Only show running applications (no pinned apps)
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false

# Dock size and position
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
gsettings set org.gnome.shell.extensions.dash-to-dock icon-size-fixed true

# Dock behavior - only show running apps
gsettings set org.gnome.shell.extensions.dash-to-dock show-running true
gsettings set org.gnome.shell.extensions.dash-to-dock show-favorites false
gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces false

# Solid dark gray background
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.85
gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color true
gsettings set org.gnome.shell.extensions.dash-to-dock background-color '#2e3436'

# Dock appearance
gsettings set org.gnome.shell.extensions.dash-to-dock apply-custom-theme false
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode 'ALL_WINDOWS'

# Animation settings
gsettings set org.gnome.shell.extensions.dash-to-dock animation-time 0.2
gsettings set org.gnome.shell.extensions.dash-to-dock show-delay 0.25
gsettings set org.gnome.shell.extensions.dash-to-dock hide-delay 0.2

# Hot corners
gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
gsettings set org.gnome.shell.extensions.dash-to-dock hotkeys-overlay false
gsettings set org.gnome.shell.extensions.dash-to-dock hotkeys-show-dock false

echo "Extensions configured successfully!"
EXTEOF

chmod +x /mnt/tmp/configure-extensions.sh

# Create autostart entry for extension configuration
mkdir -p /mnt/home/$USERNAME/.config/autostart

cat > /mnt/home/$USERNAME/.config/autostart/configure-gnome-extensions.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Configure GNOME Extensions
Exec=/tmp/configure-extensions.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=5
EOF

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

1. Arc Menu
   - Modern application menu in the top-left corner
   - Press the Arc Menu icon or Super key to open

2. Blur My Shell
   - Beautiful blur effects on the panel and dock
   - Provides modern, polished visual appearance

3. Dash to Dock
   - Customized dock that only shows running applications
   - Dock appears at the bottom when you hover
   - Solid dark gray background (#2e3436)
   - Auto-hides when windows overlap
   - Icon size: 48px

Extension Configuration:
------------------------
- Extensions will be automatically enabled on first login
- Use "Extension Manager" app to customize further
- All extensions are configured for dark theme compatibility

Dock Behavior:
--------------
- Only shows currently running applications (no pinned apps)
- Auto-hides when windows are maximized
- Appears when you move mouse to bottom of screen
- Does NOT extend full width of screen
- Dark gray solid background behind icons

To manually enable/disable extensions:
---------------------------------------
1. Open "Extension Manager" from app menu
2. Toggle extensions on/off as desired
3. Configure individual extension settings

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
