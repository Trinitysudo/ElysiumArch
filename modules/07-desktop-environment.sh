#!/usr/bin/env bash
#
# Module 07: Desktop Environment Installation
# Install Hyprland + ML4W Dotfiles (SIMPLE)
#

print_info "Installing Hyprland..."

# Install Wayland essentials
print_info "Installing Wayland and base components..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    wayland \
    xorg-xwayland \
    mesa \
    libdrm \
    polkit \
    polkit-kde-agent

print_success "Wayland essentials installed"

# Install Hyprland and all critical dependencies
print_info "Installing Hyprland and ecosystem tools..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    hyprland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    qt5-wayland \
    qt6-wayland \
    qt5ct \
    qt6ct \
    wl-clipboard \
    cliphist \
    glfw-wayland \
    cairo \
    pango

if [[ $? -ne 0 ]]; then
    print_error "Failed to install Hyprland"
    log_error "Desktop: Hyprland installation failed"
    exit 1
fi

print_success "Hyprland installed"
log_success "Desktop: Hyprland window manager installed"

# Install Waybar (top bar)
print_info "Installing Waybar..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    waybar \
    otf-font-awesome \
    ttf-font-awesome

print_success "Waybar installed"

# Install rofi-wayland (app launcher)
print_info "Installing rofi launcher..."
arch-chroot /mnt pacman -S --noconfirm --needed rofi-wayland

print_success "Rofi installed"

# Install dunst (notifications)
print_info "Installing dunst notifications..."
arch-chroot /mnt pacman -S --noconfirm --needed dunst libnotify

print_success "Dunst installed"

# Install essential tools
print_info "Installing Hyprland essential tools..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    swaylock-effects \
    swayidle \
    swaybg \
    grim \
    slurp \
    swappy \
    wf-recorder \
    brightnessctl \
    playerctl \
    pavucontrol \
    network-manager-applet \
    blueman \
    thunar \
    thunar-archive-plugin \
    thunar-volman \
    file-roller \
    gvfs \
    gvfs-mtp \
    gvfs-nfs \
    gvfs-smb \
    xdg-user-dirs \
    xdg-utils

print_success "Essential tools installed"

# No display manager needed - using TTY autologin (proper Hyprland way)

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

# File management already installed with Thunar above

# Install fonts
print_info "Installing fonts..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    ttf-dejavu \
    ttf-liberation \
    noto-fonts \
    noto-fonts-emoji \
    ttf-roboto \
    ttf-jetbrains-mono-nerd \
    ttf-fira-code \
    ttf-nerd-fonts-symbols

print_success "Fonts installed (Nerd Fonts for Hyprland)"

# Install printing support
print_info "Installing printing support..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    cups \
    cups-pdf

print_success "Printing support installed"

# Enable services
print_info "Enabling desktop services..."

# Enable Bluetooth
arch-chroot /mnt systemctl enable bluetooth
print_success "Bluetooth enabled"

# Enable CUPS
arch-chroot /mnt systemctl enable cups
print_success "Printing service enabled"

# Create essential environment files for Hyprland
print_info "Creating Hyprland environment configuration..."

# Detect if VM
IS_VM=false
if systemd-detect-virt --quiet 2>/dev/null || grep -q "hypervisor" /proc/cpuinfo 2>/dev/null; then
    IS_VM=true
    VIRT_TYPE=$(systemd-detect-virt 2>/dev/null || echo "VM")
    print_info "Virtual machine detected: $VIRT_TYPE - configuring for software rendering"
fi

# Create .bash_profile with Hyprland autostart
cat > /mnt/home/$USERNAME/.bash_profile << 'BASH_PROFILE'
# ~/.bash_profile

# Source profile for environment variables FIRST
if [ -f ~/.profile ]; then
    . ~/.profile
fi

# Auto-start Hyprland on TTY1
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec Hyprland
fi

# Source bashrc
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
BASH_PROFILE

# Create .profile with VM-optimized environment
if [[ "$IS_VM" == "true" ]]; then
    cat > /mnt/home/$USERNAME/.profile << 'PROFILE_VM'
# ~/.profile - VM OPTIMIZED

# XDG Base Directory
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Session type
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_CURRENT_DESKTOP=Hyprland

# VM SOFTWARE RENDERING (CRITICAL)
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export WLR_RENDERER=pixman
export LIBGL_ALWAYS_SOFTWARE=1
export GALLIUM_DRIVER=llvmpipe

# Disable 3D acceleration attempts
export __GLX_VENDOR_LIBRARY_NAME=mesa
export MESA_LOADER_DRIVER_OVERRIDE=llvmpipe

# Qt/GTK on Wayland
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland
export MOZ_ENABLE_WAYLAND=1
export CLUTTER_BACKEND=wayland
export SDL_VIDEODRIVER=wayland

# Cursor
export XCURSOR_SIZE=24
export XCURSOR_THEME=Adwaita
PROFILE_VM
    print_success "Created VM-optimized profile with software rendering"
else
    # Physical hardware profile
    cat > /mnt/home/$USERNAME/.profile << 'PROFILE_HW'
# ~/.profile - HARDWARE

# XDG Base Directory
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Session type
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_CURRENT_DESKTOP=Hyprland

# Qt/GTK on Wayland
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland
export MOZ_ENABLE_WAYLAND=1

# Cursor
export XCURSOR_SIZE=24
PROFILE_HW
    print_success "Created hardware-optimized profile"
fi

# Set ownership
chown $USERNAME:$USERNAME /mnt/home/$USERNAME/.bash_profile
chown $USERNAME:$USERNAME /mnt/home/$USERNAME/.profile
chmod 644 /mnt/home/$USERNAME/.bash_profile
chmod 644 /mnt/home/$USERNAME/.profile

# Configure TTY autologin
print_info "Configuring TTY autologin..."
mkdir -p /mnt/etc/systemd/system/getty@tty1.service.d
cat > /mnt/etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\\\u' --noclear --autologin $USERNAME %I \$TERM
EOF

print_success "Environment configuration created with autologin"

# Install ML4W Dotfiles (simple automated install)
print_info "Installing ML4W Dotfiles..."
arch-chroot /mnt sudo -u $USERNAME bash << 'ML4W_EOF'
cd ~
mkdir -p ~/Downloads
cd ~/Downloads
git clone --depth 1 --branch 2.9.9.3 https://github.com/mylinuxforwork/dotfiles.git
cd dotfiles
chmod +x install.sh
yes | ./install.sh || true
ML4W_EOF

print_success "ML4W Dotfiles installed"

# Create user directories
arch-chroot /mnt sudo -u $USERNAME xdg-user-dirs-update

print_success "Hyprland installation complete"
print_info "After reboot: Login and run 'Hyprland' to start"
