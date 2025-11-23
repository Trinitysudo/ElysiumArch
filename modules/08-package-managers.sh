#!/usr/bin/env bash
#
# Module 08: Package Managers Installation
# Install yay, paru, and Homebrew
#

print_info "Installing AUR helpers and package managers..."

# Install base-devel for building packages
arch-chroot /mnt pacman -S --noconfirm --needed base-devel git

# Install yay as user
print_info "Installing yay (AUR helper)..."
arch-chroot /mnt su - $USERNAME -c "
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd /
rm -rf /tmp/yay
"

if [[ $? -eq 0 ]]; then
    print_success "yay installed"
    log_success "Package Managers: yay installed"
else
    print_error "Failed to install yay"
    log_error "Package Managers: yay installation failed"
    exit 1
fi

# Install paru as user
print_info "Installing paru (alternative AUR helper)..."
arch-chroot /mnt su - $USERNAME -c "
cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd /
rm -rf /tmp/paru
"

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

# Install Homebrew (optional)
print_info "Installing Homebrew on Linux..."

# Install Homebrew dependencies
arch-chroot /mnt pacman -S --noconfirm --needed \
    gcc \
    make \
    curl

# Create Homebrew installation script
cat > /mnt/tmp/install-brew.sh << 'BREWEOF'
#!/bin/bash
# Install Homebrew as non-root user
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
BREWEOF

chmod +x /mnt/tmp/install-brew.sh

# Install Homebrew as user
arch-chroot /mnt su - $USERNAME -c "/tmp/install-brew.sh"

if [[ $? -eq 0 ]]; then
    print_success "Homebrew installed"
    log_success "Package Managers: Homebrew installed"
else
    print_warning "Failed to install Homebrew (optional)"
    log_warning "Package Managers: Homebrew installation failed"
fi

# Cleanup
rm -f /mnt/tmp/install-yay.sh /mnt/tmp/install-paru.sh /mnt/tmp/install-brew.sh

print_success "Package managers installed"
log_success "Package Managers: All package managers installed"

print_info "Installed package managers:"
print_info "  ✓ pacman (official Arch package manager)"
print_info "  ✓ yay (AUR helper - primary)"
print_info "  ✓ paru (AUR helper - alternative)"
print_info "  ✓ Homebrew (cross-platform package manager)"
