#!/usr/bin/env bash
#
# Module 10: Applications Installation
# Install user applications
#

print_info "Installing user applications..."

# Install Steam and gaming support
print_info "Installing Steam and gaming support..."

# Base Steam packages
STEAM_PACKAGES="steam vulkan-icd-loader lib32-vulkan-icd-loader"

# Add GPU-specific 32-bit libs if not in VM
if ! systemd-detect-virt --quiet; then
    if lspci | grep -i nvidia &>/dev/null; then
        print_info "Adding NVIDIA 32-bit libraries for gaming..."
        STEAM_PACKAGES="$STEAM_PACKAGES lib32-nvidia-utils"
    elif lspci | grep -i amd &>/dev/null; then
        print_info "Adding AMD 32-bit libraries for gaming..."
        STEAM_PACKAGES="$STEAM_PACKAGES lib32-vulkan-radeon lib32-libva-mesa-driver lib32-mesa-vdpau"
    elif lspci | grep -i intel &>/dev/null; then
        print_info "Adding Intel 32-bit libraries for gaming..."
        STEAM_PACKAGES="$STEAM_PACKAGES lib32-vulkan-intel lib32-libva-intel-driver"
    fi
fi

arch-chroot /mnt pacman -S --noconfirm --needed $STEAM_PACKAGES

print_success "Steam installed with GPU-specific libraries"
echo "STEAM_SUCCESS" >> /mnt/var/log/elysium/install_status

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

# Install image editing
print_info "Installing GIMP..."
arch-chroot /mnt pacman -S --noconfirm --needed gimp

print_success "GIMP installed"

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
