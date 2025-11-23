#!/usr/bin/env bash
#
# Module 10: Applications Installation
# Install user applications
#

print_info "Installing user applications..."

# Install Steam and gaming support
print_info "Installing Steam and gaming support..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    steam \
    lib32-nvidia-utils \
    vulkan-icd-loader \
    lib32-vulkan-icd-loader

print_success "Steam installed"

# Install OBS Studio
print_info "Installing OBS Studio..."
arch-chroot /mnt pacman -S --noconfirm --needed obs-studio

print_success "OBS Studio installed"

# Install media players
print_info "Installing media players..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    vlc \
    mpv

print_success "Media players installed"

# Install office suite
print_info "Installing LibreOffice..."
arch-chroot /mnt pacman -S --noconfirm --needed libreoffice-fresh

print_success "LibreOffice installed"

# Install email client
print_info "Installing Thunderbird..."
arch-chroot /mnt pacman -S --noconfirm --needed thunderbird

print_success "Thunderbird installed"

# Install image editing
print_info "Installing GIMP..."
arch-chroot /mnt pacman -S --noconfirm --needed gimp

print_success "GIMP installed"

# Install password manager
print_info "Installing KeePassXC..."
arch-chroot /mnt pacman -S --noconfirm --needed keepassxc

print_success "KeePassXC installed"

# Install file sync
print_info "Installing Syncthing..."
arch-chroot /mnt pacman -S --noconfirm --needed syncthing

print_success "Syncthing installed"

# Install torrent client
print_info "Installing Transmission..."
arch-chroot /mnt pacman -S --noconfirm --needed transmission-gtk

print_success "Transmission installed"

# Install AUR applications (require yay)
print_info "Installing AUR applications..."

# Install Visual Studio Code
print_info "Installing Visual Studio Code..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm visual-studio-code-bin"

if [[ $? -eq 0 ]]; then
    print_success "VS Code installed"
else
    print_warning "Failed to install VS Code (optional)"
fi

# Install IntelliJ IDEA Community
print_info "Installing IntelliJ IDEA Community..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm intellij-idea-community-edition"

if [[ $? -eq 0 ]]; then
    print_success "IntelliJ IDEA installed"
else
    print_warning "Failed to install IntelliJ IDEA (optional)"
fi

# Install Brave Browser
print_info "Installing Brave Browser..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm brave-bin"

if [[ $? -eq 0 ]]; then
    print_success "Brave Browser installed"
else
    print_warning "Failed to install Brave (optional)"
fi

# Install Discord
print_info "Installing Discord..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm discord"

if [[ $? -eq 0 ]]; then
    print_success "Discord installed"
else
    print_warning "Failed to install Discord (optional)"
fi

# Install Modrinth Launcher
print_info "Installing Modrinth Launcher..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm modrinth-app-bin"

if [[ $? -eq 0 ]]; then
    print_success "Modrinth Launcher installed"
else
    print_warning "Failed to install Modrinth (optional)"
fi

# Install Balena Etcher
print_info "Installing Balena Etcher..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm balena-etcher-bin"

if [[ $? -eq 0 ]]; then
    print_success "Balena Etcher installed"
else
    print_warning "Failed to install Balena Etcher (optional)"
fi

print_success "Applications installation complete"
log_success "Applications: All applications installed"
