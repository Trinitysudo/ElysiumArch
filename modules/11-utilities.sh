#!/usr/bin/env bash
#
# Module 11: Utilities Installation
# Install system utilities and tools
#

print_info "Installing system utilities..."

# Install Kate editor
print_info "Installing Kate text editor..."
arch-chroot /mnt pacman -S --noconfirm --needed kate

print_success "Kate installed"

# Install fastfetch
print_info "Installing fastfetch..."
arch-chroot /mnt pacman -S --noconfirm --needed fastfetch

print_success "fastfetch installed"

# Install Timeshift (from AUR using yay)
print_info "Installing Timeshift backup tool..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm --needed timeshift"

if [[ $? -eq 0 ]]; then
    print_success "Timeshift installed"
else
    print_warning "Timeshift installation failed (optional)"
fi

# Install system monitoring tools
print_info "Installing btop system monitor..."
arch-chroot /mnt pacman -S --noconfirm --needed btop

print_success "System monitor installed"

# Install archive tools
print_info "Installing archive tools..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    p7zip \
    unrar

print_success "Archive tools installed"

# Install essential CLI utilities
print_info "Installing CLI utilities..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    tree \
    rsync

print_success "CLI utilities installed"

print_success "Utilities installation complete"
log_success "Utilities: All utilities installed"
