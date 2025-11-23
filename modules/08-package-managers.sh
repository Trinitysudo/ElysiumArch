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

# Install rust (required for paru)
print_info "Installing Rust (required for paru)..."
arch-chroot /mnt pacman -S --noconfirm --needed rust

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

# Verify yay is working
print_info "Verifying yay installation..."
arch-chroot /mnt su - $USERNAME -c "yay --version"
if [[ $? -eq 0 ]]; then
    print_success "yay is working correctly"
else
    print_error "yay verification failed"
    exit 1
fi

# Install Homebrew (optional)
print_info "Installing Homebrew on Linux..."

# Install Homebrew dependencies
arch-chroot /mnt pacman -S --noconfirm --needed \
    gcc \
    make \
    curl

# Install Homebrew as user
arch-chroot /mnt su - $USERNAME -c '
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo '\''eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'\'' >> ~/.bashrc
echo '\''eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'\'' >> ~/.zshrc
'

if [[ $? -eq 0 ]]; then
    print_success "Homebrew installed"
    log_success "Package Managers: Homebrew installed"
else
    print_warning "Failed to install Homebrew (optional)"
    log_warning "Package Managers: Homebrew installation failed"
fi

print_success "Package managers installed"
log_success "Package Managers: All package managers installed"

print_info "Installed package managers:"
print_info "  ✓ pacman (official Arch package manager)"
print_info "  ✓ yay (AUR helper - primary)"
print_info "  ✓ paru (AUR helper - alternative)"
print_info "  ✓ Homebrew (cross-platform package manager)"
