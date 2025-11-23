#!/usr/bin/env bash
#
# Module 12: Theming - Dark Mode + macOS Icons
# Minimal theming: just dark mode and macOS-style icons
#

print_info "Applying dark theme with macOS icons..."

# Install WhiteSur icon theme (macOS-style)
print_info "Installing WhiteSur macOS icon theme..."
arch-chroot /mnt sudo -u $USERNAME bash -c "yay -S --noconfirm whitesur-icon-theme"

if [[ $? -ne 0 ]]; then
    print_warning "WhiteSur failed, trying McMojave icons..."
    arch-chroot /mnt sudo -u $USERNAME bash -c "yay -S --noconfirm mcmojave-circle-icon-theme-git"
fi

print_success "macOS icon theme installed"

# Apply GNOME dark theme
print_info "Configuring dark theme..."
mkdir -p /mnt/home/$USERNAME/.local/bin
cat > /mnt/home/$USERNAME/.local/bin/gnome-theme.sh << 'THEME_EOF'
#!/bin/bash
# Enable dark mode
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

# Set macOS-style icons
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'

# Remove autostart after first run
rm -f ~/.config/autostart/elysium-theme.desktop
THEME_EOF

chmod +x /mnt/home/$USERNAME/.local/bin/gnome-theme.sh
chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME/.local

# Create autostart
mkdir -p /mnt/home/$USERNAME/.config/autostart
cat > /mnt/home/$USERNAME/.config/autostart/elysium-theme.desktop << EOF
[Desktop Entry]
Type=Application
Name=ElysiumArch Theme
Exec=/home/$USERNAME/.local/bin/gnome-theme.sh
X-GNOME-Autostart-enabled=true
EOF

chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME/.config

print_success "Dark theme + macOS icons configured"
log_success "Theming: Minimal dark theme with macOS icons"
