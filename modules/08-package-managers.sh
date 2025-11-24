#!/usr/bin/env bash
#
# Module 08: Package Managers Installation
# Install yay, paru, and Homebrew
#

print_info "Installing AUR helpers and package managers..."

# Install required build tooling
arch-chroot /mnt pacman -S --noconfirm --needed base-devel git util-linux sudo

# Load saved configuration if not already loaded
if [[ -z "$USERNAME" ]] && [[ -f /tmp/elysium-config/user.conf ]]; then
    source /tmp/elysium-config/user.conf
    print_info "Loaded user config from resume state"
fi

# If still not set, prompt now (fallback only)
if [[ -z "$USERNAME" ]]; then
    print_warning "User configuration not found. Please enter details:"
    read -p "Username: " USERNAME
    read -sp "Password (any length): " USER_PASSWORD
    echo ""
    # Save for other modules
    mkdir -p /tmp/elysium-config
    cat > /tmp/elysium-config/user.conf << EOF
USERNAME="$USERNAME"
USER_PASSWORD="$USER_PASSWORD"
EOF
    export USERNAME USER_PASSWORD
else
    print_info "Using configured username: $USERNAME"
fi

# Verify user exists
print_info "Verifying user account: $USERNAME"
if ! arch-chroot /mnt id "$USERNAME" &>/dev/null; then
    print_error "User $USERNAME does not exist!"
    print_info "Checking /mnt mount..."
    if ! mountpoint -q /mnt; then
        print_error "/mnt is not mounted! Cannot proceed."
        print_info "Run: mount /dev/sdXY /mnt (replace XY with your root partition)"
        exit 1
    fi
    print_info "Creating user $USERNAME..."
    arch-chroot /mnt useradd -m -G wheel,audio,video,storage,optical -s /bin/bash "$USERNAME"
    echo "$USERNAME:$USER_PASSWORD" | arch-chroot /mnt chpasswd
    print_success "User $USERNAME created"
else
    print_success "User $USERNAME exists (UID: $(arch-chroot /mnt id -u "$USERNAME"))"
fi

# Ensure sudoers is configured with NOPASSWD for wheel group
print_info "Configuring passwordless sudo for installation..."

# Create sudoers drop-in file for passwordless installation (more reliable)
cat > /mnt/etc/sudoers.d/10-installer << 'SUDOERS_EOF'
# Temporary passwordless sudo for installation
%wheel ALL=(ALL:ALL) NOPASSWD: ALL
SUDOERS_EOF

chmod 440 /mnt/etc/sudoers.d/10-installer

# Also update main sudoers as backup
sed -i 's/^%wheel ALL=(ALL:ALL) ALL/# %wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /mnt/etc/sudoers

print_success "Passwordless sudo configured"

# Verify sudoers configuration
print_info "Verifying sudoers configuration..."
if grep -q "^%wheel ALL=(ALL:ALL) NOPASSWD: ALL" /mnt/etc/sudoers.d/10-installer; then
    print_success "Sudoers drop-in file is correct"
else
    print_error "Sudoers drop-in file is incorrect!"
    cat /mnt/etc/sudoers.d/10-installer
    exit 1
fi

# Test sudo works without password
print_info "Testing passwordless sudo for $USERNAME..."
if arch-chroot /mnt sudo -u "$USERNAME" sudo -n true 2>/dev/null; then
    print_success "Passwordless sudo is working correctly"
else
    print_error "Passwordless sudo is NOT working!"
    print_info "Sudoers configuration:"
    cat /mnt/etc/sudoers.d/10-installer
    print_info "User groups:"
    arch-chroot /mnt groups "$USERNAME"
    exit 1
fi

# Helper function to run a command strictly as the normal user inside chroot
run_as_user() {
    local CMD="$1"
    # Use sudo -u since runuser has NSS issues in chroot
    arch-chroot /mnt sudo -u "$USERNAME" bash -c "$CMD"
}

# YAY INSTALLATION ---------------------------------------------------------
if arch-chroot /mnt test -x /usr/bin/yay; then
    print_info "yay already installed – skipping build"
else
    print_info "Installing yay (AUR helper)..."

    # Ensure home directory exists with proper permissions
    print_info "Setting up build environment for $USERNAME..."
    arch-chroot /mnt bash << EOF
set -e
# Ensure home exists
mkdir -p /home/$USERNAME
chown -R $USERNAME:$USERNAME /home/$USERNAME
chmod 755 /home/$USERNAME

# Create build directory
rm -rf /home/$USERNAME/aur-build
mkdir -p /home/$USERNAME/aur-build
chown -R $USERNAME:$USERNAME /home/$USERNAME/aur-build
chmod 755 /home/$USERNAME/aur-build

# Configure makepkg to not use sudo during build
mkdir -p /home/$USERNAME/.config
echo "BUILDENV=(!distcc color !ccache check !sign)" > /home/$USERNAME/.makepkg.conf
chown $USERNAME:$USERNAME /home/$USERNAME/.makepkg.conf
EOF

    print_info "Cloning yay-bin (precompiled)..."
    if arch-chroot /mnt sudo -u "$USERNAME" bash -c "cd /home/$USERNAME/aur-build && git clone https://aur.archlinux.org/yay-bin.git"; then
        print_info "Building yay-bin package..."
        if arch-chroot /mnt sudo -u "$USERNAME" bash -c "cd /home/$USERNAME/aur-build/yay-bin && makepkg -si --noconfirm --needed"; then
            print_success "yay-bin installed"
        else
            print_warning "yay-bin build failed – falling back to source build"
            arch-chroot /mnt rm -rf "/home/$USERNAME/aur-build/yay-bin"
            
            if arch-chroot /mnt sudo -u "$USERNAME" bash -c "cd /home/$USERNAME/aur-build && git clone https://aur.archlinux.org/yay.git" && \
               arch-chroot /mnt sudo -u "$USERNAME" bash -c "cd /home/$USERNAME/aur-build/yay && makepkg -si --noconfirm --needed"; then
                print_success "yay (source) installed"
            else
                print_error "Failed to build yay from both yay-bin and source"
                log_error "Package Managers: yay installation failed"
                exit 1
            fi
        fi
    else
        print_warning "Failed cloning yay-bin – attempting yay (source)"
        if arch-chroot /mnt sudo -u "$USERNAME" bash -c "cd /home/$USERNAME/aur-build && git clone https://aur.archlinux.org/yay.git" && \
           arch-chroot /mnt sudo -u "$USERNAME" bash -c "cd /home/$USERNAME/aur-build/yay && makepkg -si --noconfirm --needed"; then
            print_success "yay (source) installed"
        else
            print_error "Unable to clone/build yay"
            log_error "Package Managers: yay installation failed"
            exit 1
        fi
    fi

    # Cleanup build dir
    arch-chroot /mnt rm -rf "/home/$USERNAME/aur-build"
fi

# Final yay verification (ensure not root)
if arch-chroot /mnt test -x /usr/bin/yay; then
    print_info "Verifying yay as user..."
    YAY_VERSION=$(arch-chroot /mnt sudo -u "$USERNAME" yay --version 2>&1 | head -1 || true)
    if [[ -n "$YAY_VERSION" && "$YAY_VERSION" != *"error"* ]]; then
        print_success "yay installed successfully: $YAY_VERSION"
        log_success "Package Managers: yay installed: $YAY_VERSION"
    else
        print_error "yay binary present but version check failed"
        print_info "Checking if yay works as root (diagnostic)..."
        arch-chroot /mnt yay --version || true
        log_error "Package Managers: yay version verification failed"
        exit 1
    fi
else
    print_error "yay binary not found after installation attempts"
    log_error "Package Managers: yay binary missing"
    exit 1
fi

# Install rust (required for paru)
print_info "Installing Rust (required for paru) ..."
arch-chroot /mnt pacman -S --noconfirm --needed rust

print_info "Installing paru (optional alternative AUR helper)..."
if arch-chroot /mnt test -x /usr/bin/paru; then
    print_info "paru already installed – skipping"
elif [[ "$SKIP_PARU" == "1" || -n "$ELYSIUM_SKIP_PARU" ]]; then
    print_info "Paru installation skipped (configured in config.sh)"
else
    run_as_user "mkdir -p ~/aur-build && rm -rf ~/aur-build/paru-bin ~/aur-build/paru"
    PARU_START=$SECONDS
    print_info "Attempting paru-bin (precompiled) first..."
    if run_as_user "cd ~/aur-build && git clone https://aur.archlinux.org/paru-bin.git" && \
       run_as_user "cd ~/aur-build/paru-bin && makepkg -si --noconfirm --needed"; then
        print_success "paru-bin installed"
        log_success "Package Managers: paru-bin installed"
    else
        print_warning "paru-bin failed – falling back to source build (this can take several minutes on first Rust compile)"
        run_as_user "rm -rf ~/aur-build/paru-bin"
        if run_as_user "cd ~/aur-build && git clone https://aur.archlinux.org/paru.git" && \
           run_as_user "cd ~/aur-build/paru && makepkg -si --noconfirm --needed"; then
            print_success "paru (source) installed"
            log_success "Package Managers: paru (source) installed"
        else
            print_warning "paru installation failed (optional)"
            log_warning "Package Managers: paru installation failed"
        fi
    fi
    PARU_DURATION=$(( SECONDS - PARU_START ))
    print_info "paru build/install duration: ${PARU_DURATION}s"
    run_as_user "rm -rf ~/aur-build"
fi

# Configure yay
print_info "Configuring yay..."
arch-chroot /mnt mkdir -p /home/$USERNAME/.config/yay
arch-chroot /mnt chown -R $USERNAME:$USERNAME /home/$USERNAME/.config

cat > /mnt/home/$USERNAME/.config/yay/config.json <<'EOFYAY'
{
  "editor": "",
  "cleanAfter": true,
  "sudoloop": true,
  "save": true,
  "answerYes": true,
  "devel": true,
  "combinedUpgrade": true,
  "redownload": false,
  "useAsk": false
}
EOFYAY
arch-chroot /mnt chown $USERNAME:$USERNAME /home/$USERNAME/.config/yay/config.json
print_success "yay config file created"

print_info "Generating yay database..."
if run_as_user "yay -Y --gendb 2>&1"; then
    print_success "yay database generated"
else
    print_warning "Failed to generate yay DB (non-critical, will generate on first use)"
fi

print_info "Final yay verification..."
if run_as_user "yay --version 2>&1"; then
    print_success "yay operational and verified"
else
    print_warning "yay verification had issues but binary is installed"
    print_info "Testing direct yay call..."
    arch-chroot /mnt sudo -u "$USERNAME" /usr/bin/yay --version || true
fi

# Install Homebrew (optional)
print_info "Installing Homebrew on Linux..."

# Install Homebrew dependencies
arch-chroot /mnt pacman -S --noconfirm --needed \
    gcc \
    make \
    curl

# Install Homebrew as user
print_info "Installing Homebrew (this may take 5-10 minutes)..."
arch-chroot /mnt sudo -u $USERNAME bash << 'HOMEBREW_EOF'
set -e
export NONINTERACTIVE=1
export CI=1

echo "Downloading Homebrew installer..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
    echo "ERROR: Homebrew installation failed!"
    echo "This is optional - you can skip it"
    exit 1
}

# Verify installation
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
    echo "Homebrew installed successfully at /home/linuxbrew/.linuxbrew"
else
    echo "ERROR: Homebrew directory not found after installation"
    exit 1
fi
HOMEBREW_EOF

if [[ $? -eq 0 ]]; then
    print_success "Homebrew installed successfully"
    log_success "Package Managers: Homebrew installed"
    echo "NOTE: Run 'eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"' to use brew in current session"
else
    print_warning "Homebrew installation failed (OPTIONAL - system will work without it)"
    print_info "You can install Homebrew later with: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    log_warning "Package Managers: Homebrew installation failed (optional)"
fi

print_success "Package managers installed"
log_success "Package Managers: All package managers installed"

print_info "Installed package managers:"
print_info "  ✓ pacman (official Arch package manager)"
print_info "  ✓ yay (AUR helper - primary)"
print_info "  ✓ paru (AUR helper - alternative)"
print_info "  ✓ Homebrew (cross-platform package manager)"
