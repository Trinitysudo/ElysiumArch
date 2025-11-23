#!/usr/bin/env bash
#
# Module 12: Theming and Visual Customization
# Apply dark theme, blue accents, and visual customizations
#

print_info "Applying system theme and visual customizations..."

# Install icon themes
print_info "Installing icon themes..."
arch-chroot /mnt pacman -S --noconfirm --needed papirus-icon-theme

# Install from AUR
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm tela-icon-theme"

print_success "Icon themes installed"

# Install GTK themes
print_info "Installing GTK themes..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm orchis-theme-git"

print_success "GTK themes installed"

# Apply GNOME dark theme with blue accent
print_info "Configuring GNOME theme settings..."

# Create dconf profile for user
mkdir -p /mnt/home/$USERNAME/.config/dconf

# Apply theme settings (will take effect after first login)
mkdir -p /mnt/home/$USERNAME/.local/bin
cat > /mnt/home/$USERNAME/.local/bin/gnome-theme.sh << 'THEME_EOF'
#!/bin/bash
# Apply dark theme
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Set blue accent
gsettings set org.gnome.desktop.interface accent-color 'blue'

# Set icon theme
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# Set cursor theme
gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'

# Configure fonts
gsettings set org.gnome.desktop.interface font-name 'Ubuntu 11'
gsettings set org.gnome.desktop.interface document-font-name 'Ubuntu 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 13'

# Enable dark theme for legacy applications
gsettings set org.gnome.desktop.interface gtk-application-prefer-dark-theme true

# Remove this autostart file after first run
rm -f ~/.config/autostart/elysium-theme.desktop
THEME_EOF

chmod +x /mnt/home/$USERNAME/.local/bin/gnome-theme.sh
chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME/.local

print_success "Theme configuration created"

# Install live wallpaper engine (Komorebi)
print_info "Installing Komorebi (live wallpapers)..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm komorebi"

if [[ $? -eq 0 ]]; then
    print_success "Komorebi installed"
else
    print_warning "Failed to install Komorebi (optional)"
fi

# Create autostart script for theme application
mkdir -p /mnt/home/$USERNAME/.config/autostart
cat > /mnt/home/$USERNAME/.config/autostart/elysium-theme.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=ElysiumArch Theme
Exec=/home/$USERNAME/.local/bin/gnome-theme.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# Replace $USERNAME in desktop file
sed -i "s/\$USERNAME/$USERNAME/g" /mnt/home/$USERNAME/.config/autostart/elysium-theme.desktop

chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME/.config

print_success "Theming configuration complete"
log_success "Theming: Dark theme with blue accent configured"

print_info "Theme settings will be applied on first login"
