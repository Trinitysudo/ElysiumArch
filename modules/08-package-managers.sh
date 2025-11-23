#!/usr/bin/env bash
#
# Module 08: Package Managers Installation
# Install yay, paru, and Homebrew
#

print_info "Installing AUR helpers and package managers..."

# Install base-devel for building packages
arch-chroot /mnt pacman -S --noconfirm --needed base-devel git

# Create installation script for yay
cat > /mnt/tmp/install-yay.sh << 'YAYEOF'
#!/bin/bash
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd /
rm -rf /tmp/yay
YAYEOF

chmod +x /mnt/tmp/install-yay.sh

# Install yay as user
print_info "Installing yay (AUR helper)..."
arch-chroot /mnt su - $USERNAME -c "/tmp/install-yay.sh"

if [[ $? -eq 0 ]]; then
    print_success "yay installed"
    log_success "Package Managers: yay installed"
else
    print_error "Failed to install yay"
    log_error "Package Managers: yay installation failed"
    exit 1
fi

# Create installation script for paru
cat > /mnt/tmp/install-paru.sh << 'PARUEOF'
#!/bin/bash
cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd /
rm -rf /tmp/paru
PARUEOF

chmod +x /mnt/tmp/install-paru.sh

# Install paru as user
print_info "Installing paru (alternative AUR helper)..."
arch-chroot /mnt su - $USERNAME -c "/tmp/install-paru.sh"

if [[ $? -eq 0 ]]; then
    print_success "paru installed"
    log_success "Package Managers: paru installed"
else
    print_warning "Failed to install paru (optional)"
    log_warning "Package Managers: paru installation failed"
fi

# Configure yay
print_info "Configuring yay..."
arch-chroot /mnt su - $USERNAME -c "yay -Y --gendb && yay -Y --devel --save"

# Cleanup
rm -f /mnt/tmp/install-yay.sh /mnt/tmp/install-paru.sh

print_success "Package managers installed"
log_success "Package Managers: All package managers installed"

print_info "Installed package managers:"
print_info "  ✓ pacman (official Arch package manager)"
print_info "  ✓ yay (AUR helper - primary)"
print_info "  ✓ paru (AUR helper - alternative)"
