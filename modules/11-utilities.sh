#!/usr/bin/env bash
#
# Module 11: Utilities Installation
# Install system utilities and tools
#

print_info "Installing system utilities..."

# Install Kitty terminal
print_info "Installing Kitty terminal..."
arch-chroot /mnt pacman -S --noconfirm --needed kitty

print_success "Kitty installed"

# Install Kate editor
print_info "Installing Kate editor..."
arch-chroot /mnt pacman -S --noconfirm --needed kate

print_success "Kate installed"

# Install Timeshift
print_info "Installing Timeshift..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm timeshift"

if [[ $? -eq 0 ]]; then
    print_success "Timeshift installed"
else
    print_warning "Failed to install Timeshift (optional)"
fi

# Install fastfetch
print_info "Installing fastfetch..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm fastfetch"

if [[ $? -eq 0 ]]; then
    print_success "fastfetch installed"
else
    print_warning "Failed to install fastfetch (optional)"
fi

# Install system monitoring tools
print_info "Installing system monitoring tools..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    htop \
    btop

print_success "System monitors installed"

# Install nvtop for NVIDIA
print_info "Installing nvtop (NVIDIA GPU monitor)..."
arch-chroot /mnt pacman -S --noconfirm --needed nvtop

print_success "nvtop installed"

# Install archive tools
print_info "Installing archive tools..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    p7zip \
    unrar \
    file-roller

print_success "Archive tools installed"

# Install shell enhancements
print_info "Installing shell enhancements..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    zsh \
    fzf \
    ripgrep \
    fd \
    bat

# Install starship prompt
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm starship"

print_success "Shell enhancements installed"

# Install CLI utilities
print_info "Installing CLI utilities..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    ncdu \
    tree \
    rsync

print_success "CLI utilities installed"

print_success "Utilities installation complete"
log_success "Utilities: All utilities installed"
