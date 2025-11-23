#!/usr/bin/env bash
#
# Module 07: Desktop Environment Installation
# Install GNOME desktop environment with all components
#

print_info "Installing GNOME desktop environment..."

# Install Xorg and display servers
print_info "Installing display servers..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    xorg-server \
    xorg-apps \
    xorg-xinit \
    xf86-input-libinput \
    mesa \
    wayland \
    xorg-xwayland

print_success "Display servers installed"
log_success "Desktop: Display servers installed"

# Install GNOME
print_info "Installing GNOME desktop environment (this may take 15-20 minutes)..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    gnome \
    gnome-extra \
    gnome-tweaks \
    dconf-editor \
    chrome-gnome-shell

if [[ $? -ne 0 ]]; then
    print_error "Failed to install GNOME"
    log_error "Desktop: GNOME installation failed"
    exit 1
fi

print_success "GNOME installed"
log_success "Desktop: GNOME desktop installed"

# Install GDM (display manager)
print_info "Installing GDM display manager..."
arch-chroot /mnt pacman -S --noconfirm --needed gdm

print_success "GDM installed"

# Install audio system (PipeWire)
print_info "Installing audio system..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-jack \
    wireplumber \
    pavucontrol

print_success "Audio system installed"

# Install Bluetooth
print_info "Installing Bluetooth support..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    bluez \
    bluez-utils \
    blueman

print_success "Bluetooth installed"

# Install file management
print_info "Installing file management tools..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    nautilus \
    file-roller \
    gvfs \
    gvfs-mtp \
    gvfs-nfs \
    gvfs-smb

print_success "File management installed"

# Install fonts
print_info "Installing fonts..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    ttf-dejavu \
    ttf-liberation \
    noto-fonts \
    noto-fonts-emoji \
    ttf-roboto \
    ttf-ubuntu-font-family

print_success "Fonts installed"

# Install printing support
print_info "Installing printing support..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    cups \
    cups-pdf

print_success "Printing support installed"

# Install screenshot tools
arch-chroot /mnt pacman -S --noconfirm --needed gnome-screenshot

# Enable services
print_info "Enabling desktop services..."

# Enable GDM
arch-chroot /mnt systemctl enable gdm
print_success "GDM enabled (graphical login)"

# Enable Bluetooth
arch-chroot /mnt systemctl enable bluetooth
print_success "Bluetooth enabled"

# Enable CUPS
arch-chroot /mnt systemctl enable cups
print_success "Printing service enabled"

print_success "Desktop environment installation complete"
log_success "Desktop: All components installed and services enabled"

print_info "GNOME will start automatically on next boot"
