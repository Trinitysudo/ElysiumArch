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
fi

# If still not set, prompt now
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
print_info "Verifying sudo configuration..."
if ! grep -q "^%wheel ALL=(ALL:ALL) NOPASSWD: ALL" /mnt/etc/sudoers; then
    print_warning "NOPASSWD not configured - fixing sudoers..."
    sed -i 's/^%wheel ALL=(ALL:ALL) ALL/# %wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers
    sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /mnt/etc/sudoers
fi

# Test sudo works
print_info "Testing sudo -u $USERNAME..."
if ! arch-chroot /mnt sudo -u "$USERNAME" whoami &>/dev/null; then
    print_error "sudo -u $USERNAME is not working"
    print_info "Sudoers wheel lines:"
    grep wheel /mnt/etc/sudoers || true
    print_info "User groups:"
    arch-chroot /mnt groups "$USERNAME" || true
    print_info "Testing direct command..."
    arch-chroot /mnt su - "$USERNAME" -c "whoami" || true
    exit 1
fi
print_success "sudo configured and working"

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

    # Prepare user build workspace
    run_as_user "mkdir -p ~/aur-build && rm -rf ~/aur-build/yay-bin ~/aur-build/yay"

    print_info "Cloning yay-bin (precompiled) ..."
    if run_as_user "cd ~/aur-build && git clone https://aur.archlinux.org/yay-bin.git"; then
        print_info "Building yay-bin package..."
        if run_as_user "cd ~/aur-build/yay-bin && makepkg -si --noconfirm --needed"; then
            print_success "yay-bin installed"
        else
            print_warning "yay-bin build failed – falling back to source build of yay"
            run_as_user "rm -rf ~/aur-build/yay-bin"
            if run_as_user "cd ~/aur-build && git clone https://aur.archlinux.org/yay.git" && \
               run_as_user "cd ~/aur-build/yay && makepkg -si --noconfirm --needed"; then
                print_success "yay (source) installed"
            else
                print_error "Failed to build yay from both yay-bin and source"
                log_error "Package Managers: yay installation failed"
                exit 1
            fi
        fi
    else
        print_warning "Failed cloning yay-bin – attempting cloning yay (source)"
        if run_as_user "cd ~/aur-build && git clone https://aur.archlinux.org/yay.git" && \
           run_as_user "cd ~/aur-build/yay && makepkg -si --noconfirm --needed"; then
            print_success "yay (source) installed"
        else
            print_error "Unable to clone/build yay"
            log_error "Package Managers: yay installation failed"
            exit 1
        fi
    fi

    # Cleanup build dir (leave only if debugging needed)
    run_as_user "rm -rf ~/aur-build"
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
elif [[ -n "$ELYSIUM_SKIP_PARU" ]]; then
    print_info "ELYSIUM_SKIP_PARU set – skipping paru install"
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
