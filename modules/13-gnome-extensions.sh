#!/usr/bin/env bash
#
# Module 13: GNOME Extensions Installation
# Install and configure GNOME Shell extensions
#

print_info "Installing GNOME extensions..."

# Install Extension Manager
print_info "Installing Extension Manager..."
arch-chroot /mnt pacman -S --noconfirm --needed gnome-shell-extensions

# Install extension manager from Flatpak
arch-chroot /mnt pacman -S --noconfirm --needed flatpak
arch-chroot /mnt su - $USERNAME -c "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
arch-chroot /mnt su - $USERNAME -c "flatpak install -y flathub com.mattjakeman.ExtensionManager"

print_success "Extension Manager installed"

# Install common extensions via packages
print_info "Installing GNOME extension packages..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-dash-to-dock

print_success "Core extensions installed"

# Create extension installation script for first boot
cat > /mnt/home/$USERNAME/install-extensions.sh << 'EOF'
#!/bin/bash
# This script will install additional GNOME extensions on first login

echo "Installing GNOME extensions..."

# Enable installed extensions
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
gnome-extensions enable dash-to-dock@micxgx.gmail.com

echo "Extensions enabled!"
echo "Open Extension Manager to browse and install more extensions"
echo "This script has completed and can be deleted."
EOF

chmod +x /mnt/home/$USERNAME/install-extensions.sh
chown $USERNAME:$USERNAME /mnt/home/$USERNAME/install-extensions.sh

print_success "GNOME extensions installation complete"
log_success "GNOME Extensions: Core extensions installed"

print_info "Extension Manager is installed for easy extension management"
print_info "Run ~/install-extensions.sh after first login to enable extensions"
