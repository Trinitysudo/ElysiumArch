#!/usr/bin/env bash
#
# Module 12: Theming - Dark Mode + Tela Dark Icons
# Minimal theming: dark mode with beautiful Tela dark icons
#

print_info "Applying dark theme with Tela dark icons..."

# Install Tela icon theme (beautiful, flat, colorful dark icons)
print_info "Installing Tela dark icon theme (only dark variant)..."
arch-chroot /mnt sudo -u $USERNAME bash -c "yay -S --noconfirm tela-icon-theme"

if [[ $? -ne 0 ]]; then
    print_error "Tela installation failed!"
    exit 1
fi

# Remove all non-dark variants to save space
print_info "Removing light Tela variants (keeping only dark)..."
TELA_DIR="/mnt/usr/share/icons"
if [ -d "$TELA_DIR" ]; then
    # Remove all Tela variants except dark ones
    arch-chroot /mnt bash << 'CLEANUP_EOF'
cd /usr/share/icons
# Keep only Tela-dark and Tela-black-dark, remove all others
for theme in Tela Tela-blue Tela-green Tela-grey Tela-orange Tela-pink Tela-purple Tela-red Tela-yellow Tela-brown Tela-black Tela-blue-dark Tela-green-dark Tela-grey-dark Tela-orange-dark Tela-pink-dark Tela-purple-dark Tela-red-dark Tela-yellow-dark Tela-brown-dark; do
    if [ -d "$theme" ]; then
        rm -rf "$theme"
        echo "Removed: $theme"
    fi
done
echo "Kept: Tela-dark and Tela-black-dark only"
CLEANUP_EOF
fi

print_success "Tela dark icon theme installed (light variants removed)"

# Apply GNOME dark theme with blue accent
print_info "Configuring dark theme with blue accent..."
mkdir -p /mnt/home/$USERNAME/.local/bin
cat > /mnt/home/$USERNAME/.local/bin/gnome-theme.sh << 'THEME_EOF'
#!/bin/bash
# Enable dark mode
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

# Set Tela dark icons
gsettings set org.gnome.desktop.interface icon-theme 'Tela-dark'

# Set blue accent color
gsettings set org.gnome.desktop.interface accent-color 'blue'

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
