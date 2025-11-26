#!/usr/bin/env bash
#
# Module 07: Desktop Environment Installation
# Install Hyprland + ML4W Dotfiles
#

print_info "Installing Hyprland..."

# Install Wayland essentials
print_info "Installing Wayland and base components..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    wayland \
    xorg-xwayland \
    mesa \
    libdrm \
    polkit \
    polkit-kde-agent

# Install Hyprland and ecosystem
arch-chroot /mnt pacman -S --noconfirm --needed \
    hyprland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    qt5-wayland \
    qt6-wayland \
    qt5ct \
    qt6ct \
    wl-clipboard \
    glfw-wayland \
    cairo \
    pango \
    kitty \
    waybar \
    rofi-wayland \
    dunst \
    libnotify \
    swaylock-effects \
    grim \
    slurp \
    brightnessctl \
    playerctl \
    network-manager-applet \
    blueman \
    thunar \
    xdg-user-dirs \
    xdg-utils

if [[ $? -ne 0 ]]; then
    print_error "Failed to install Hyprland"
    exit 1
fi

print_success "Hyprland packages installed"

# Install audio system
arch-chroot /mnt pacman -S --noconfirm --needed \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-jack \
    wireplumber

# Install Bluetooth
arch-chroot /mnt pacman -S --noconfirm --needed \
    bluez \
    bluez-utils

# Install fonts
arch-chroot /mnt pacman -S --noconfirm --needed \
    ttf-dejavu \
    ttf-liberation \
    noto-fonts \
    noto-fonts-emoji \
    ttf-jetbrains-mono-nerd

# Enable services
arch-chroot /mnt systemctl enable bluetooth
arch-chroot /mnt systemctl enable cups 2>/dev/null || true

# Install ML4W Dotfiles
print_info "Installing ML4W Dotfiles..."
arch-chroot /mnt sudo -u $USERNAME bash << 'ML4W_EOF'
cd ~
mkdir -p ~/Downloads
cd ~/Downloads
git clone --depth 1 --branch 2.9.9.3 https://github.com/mylinuxforwork/dotfiles.git
cd dotfiles
chmod +x install.sh
yes | ./install.sh || true
ML4W_EOF

print_success "Hyprland + ML4W Dotfiles installed"
