#!/usr/bin/env bash
#
# Module 08: Package Managers Installation
# Install yay, paru, and Homebrew
#

print_info "Installing AUR helpers and package managers..."

# Install base-devel for building packages
arch-chroot /mnt pacman -S --noconfirm --needed base-devel git

# Install yay-bin as user (precompiled binary - much faster)
print_info "Installing yay (AUR helper)..."

# Create build directory in user's home and set ownership
arch-chroot /mnt mkdir -p /home/$USERNAME/aur-build
arch-chroot /mnt chown -R $USERNAME:$USERNAME /home/$USERNAME/aur-build

# Clone and build as user directly
print_info "Cloning yay-bin..."
arch-chroot /mnt sudo -u $USERNAME bash -c 'cd ~ && mkdir -p aur-build && cd aur-build && git clone https://aur.archlinux.org/yay-bin.git'

print_info "Building and installing yay..."
arch-chroot /mnt sudo -u $USERNAME bash -c 'cd ~/aur-build/yay-bin && makepkg -si --noconfirm --needed'

YAY_BUILD_EXIT=$?

# Cleanup
arch-chroot /mnt rm -rf /home/$USERNAME/aur-build

if [[ $YAY_BUILD_EXIT -ne 0 ]]; then
    print_error "Failed to install yay (exit code: $YAY_BUILD_EXIT)"
    log_error "Package Managers: yay installation failed"
    arch-chroot /mnt rm -rf /home/$USERNAME/aur-build
    exit 1
fi

# Cleanup
arch-chroot /mnt rm -rf /home/$USERNAME/aur-build

# Verify yay binary exists
if arch-chroot /mnt test -f /usr/bin/yay; then
    print_success "yay installed successfully"
    log_success "Package Managers: yay installed"
else
    print_error "yay binary not found after installation"
    log_error "Package Managers: yay binary missing"
    exit 1
fi

# Install rust (required for paru)
print_info "Installing Rust (required for paru)..."
arch-chroot /mnt pacman -S --noconfirm --needed rust

# Install paru as user
print_info "Installing paru (alternative AUR helper)..."

# Create build directory in user's home and set ownership
arch-chroot /mnt mkdir -p /home/$USERNAME/aur-build
arch-chroot /mnt chown -R $USERNAME:$USERNAME /home/$USERNAME/aur-build

# Clone and build as user directly
print_info "Cloning paru..."
arch-chroot /mnt sudo -u $USERNAME bash -c 'cd ~ && mkdir -p aur-build && cd aur-build && git clone https://aur.archlinux.org/paru.git'

print_info "Building and installing paru..."
arch-chroot /mnt sudo -u $USERNAME bash -c 'cd ~/aur-build/paru && makepkg -si --noconfirm --needed'

PARU_BUILD_EXIT=$?

# Cleanup
arch-chroot /mnt rm -rf /home/$USERNAME/aur-build

if [[ $PARU_BUILD_EXIT -ne 0 ]]; then
    print_warning "Failed to install paru (optional, exit code: $PARU_BUILD_EXIT)"
    log_warning "Package Managers: paru installation failed"
else
    print_success "paru installed"
    log_success "Package Managers: paru installed"
fi

# Cleanup
arch-chroot /mnt rm -rf /home/$USERNAME/aur-build

# Configure yay
print_info "Configuring yay..."
arch-chroot /mnt su - $USERNAME -c "
export PATH=\"\$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin\"
yay -Y --gendb
yay -Y --devel --save
"

if [[ $? -eq 0 ]]; then
    print_success "yay configured"
else
    print_warning "yay configuration had issues (non-critical)"
fi

# Verify yay is working
print_info "Verifying yay installation..."
arch-chroot /mnt su - $USERNAME -c "
export PATH=\"\$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin\"
which yay
yay --version
"

if [[ $? -eq 0 ]]; then
    print_success "yay is working correctly"
else
    print_error "yay verification failed"
    print_info "Checking yay location..."
    arch-chroot /mnt find /usr /home/$USERNAME -name yay -type f 2>/dev/null
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
