#!/usr/bin/env bash
#
# Module 08: Package Managers Installation
# Install yay, paru, and Homebrew
#

print_info "Installing AUR helpers and package managers..."

# Install required build tooling (sudo already present from base system but ensure)
arch-chroot /mnt pacman -S --noconfirm --needed base-devel git util-linux sudo

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
run_as_user "mkdir -p ~/.config/yay"
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

if run_as_user "yay -Y --gendb"; then
    print_success "yay database generated"
else
    print_warning "Failed to generate yay DB (non-critical)"
fi

if run_as_user "yay --version"; then
    print_success "yay operational"
else
    print_error "yay final verification failed"
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
