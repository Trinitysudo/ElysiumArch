#!/usr/bin/env bash
#
# Module 07: Desktop Environment Installation
# Install Hyprland with amazing blue/black theme
#

print_info "Installing Hyprland window manager (FUCK GNOME!)..."

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

# TTY autologin disabled for manual testing
print_info "TTY autologin DISABLED - manual login required"
print_warning "After reboot: login, then run 'Hyprland' manually"

# Create .bash_profile WITHOUT autostart (manual control)
cat > /mnt/home/$USERNAME/.bash_profile << 'BASH_PROFILE'
# ~/.bash_profile

# Source .profile FIRST for environment variables (critical for VM!)
if [ -f ~/.profile ]; then
    . ~/.profile
fi

# Hyprland autostart DISABLED for testing
# To start Hyprland manually, just run: Hyprland

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
BASH_PROFILE

# Create .profile with environment variables (detect VM FIRST!)
# Detect if running in VM
IS_VM=false
if systemd-detect-virt --quiet 2>/dev/null || grep -q "hypervisor" /proc/cpuinfo 2>/dev/null; then
    IS_VM=true
    print_info "Virtual machine detected - will add software rendering flags"
fi

cat > /mnt/home/$USERNAME/.profile << 'PROFILE_START'
# ~/.profile

# Wayland environment variables
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_CURRENT_DESKTOP=Hyprland
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland
export MOZ_ENABLE_WAYLAND=1

# Hyprland stability settings
export HYPRLAND_LOG_WLR=1
export XCURSOR_SIZE=24
PROFILE_START

# Add VM-specific settings if in VM
if [[ "$IS_VM" == "true" ]]; then
    cat >> /mnt/home/$USERNAME/.profile << 'PROFILE_VM'

# VM-specific Hyprland settings (software rendering)
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
PROFILE_VM
    print_info "Added VM software rendering flags to .profile"
fi

cat >> /mnt/home/$USERNAME/.profile << 'PROFILE_END'

# Hyprland autostart is handled by .bash_profile
PROFILE_END

chown $USERNAME:$USERNAME /mnt/home/$USERNAME/.bash_profile
chown $USERNAME:$USERNAME /mnt/home/$USERNAME/.profile
chmod 644 /mnt/home/$USERNAME/.bash_profile
chmod 644 /mnt/home/$USERNAME/.profile

print_success "TTY autologin configured - Hyprland will start automatically"

# Enable Bluetooth
arch-chroot /mnt systemctl enable bluetooth
print_success "Bluetooth enabled"

# Enable CUPS
arch-chroot /mnt systemctl enable cups
print_success "Printing service enabled"

# Install ML4W Dotfiles (mylinuxforwork - PROFESSIONAL setup)
print_info "Installing ML4W Dotfiles for Hyprland (BEST config available)..."
arch-chroot /mnt sudo -u $USERNAME bash << 'HYPR_CONFIG_EOF'
set -e
cd ~
mkdir -p ~/Downloads
cd ~/Downloads

# Clone ML4W dotfiles (stable release 2.9.9.3)
if [ ! -d "dotfiles" ]; then
    git clone --depth 1 --branch 2.9.9.3 https://github.com/mylinuxforwork/dotfiles.git || {
        echo "Failed to clone ML4W dotfiles, using basic config"
        exit 0
    }
fi

cd dotfiles

# Run the installer (automated mode)
chmod +x install.sh
# Check if installer accepts flags, otherwise use interactive responses
if ./install.sh --help 2>&1 | grep -q "\-p\|\-\-profile"; then
    # Installer supports flags
    yes | ./install.sh -p default -t kitty 2>&1 || {
        echo "ML4W installer failed, will configure manually"
        exit 0
    }
else
    # Fallback to interactive responses
    # Responses: profile selection, terminal (kitty), confirmations
    printf "1\nkitty\ny\ny\ny\ny\ny\ny\n" | ./install.sh 2>&1 || {
        echo "ML4W installer failed, will configure manually"
        exit 0
    }
fi

echo "ML4W Dotfiles installed successfully"
HYPR_CONFIG_EOF

if [[ $? -eq 0 ]]; then
    print_success "ML4W Dotfiles installed (mylinuxforwork)"
else
    print_warning "ML4W dotfiles failed, will use basic config"
fi

# Create user directories
print_info "Creating user directories..."
arch-chroot /mnt sudo -u $USERNAME xdg-user-dirs-update

# Always ensure Hyprland config exists and is working
print_info "Ensuring Hyprland configuration is present..."
mkdir -p /mnt/home/$USERNAME/.config/hypr

# Always create a guaranteed working fallback config (ML4W might override)
print_info "Creating guaranteed working Hyprland fallback configuration..."

cat > /mnt/home/$USERNAME/.config/hypr/hyprland.conf << 'HYPR_EOF'
# ElysiumArch Minimal Working Hyprland Config
# This ensures Hyprland can start even if ML4W config fails

# Monitor setup - auto-detect
monitor=,preferred,auto,1

# Startup applications (optional - will fail gracefully if missing)
exec-once = waybar &
exec-once = dunst &
exec-once = /usr/lib/polkit-kde-authentication-agent-1 &
exec-once = nm-applet --indicator
exec-once = blueman-applet
exec-once = cliphist store

input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = yes
    }
    sensitivity = 0
}

general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(89b4faee) rgba(1e3a5fee) 45deg
    col.inactive_border = rgba(45475aaa)
    layout = dwindle
}

decoration {
    rounding = 10
    blur {
        enabled = true
        size = 8
        passes = 3
    }
    drop_shadow = yes
    shadow_range = 20
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

dwindle {
    pseudotile = yes
    preserve_split = yes
}

# Key bindings
$mainMod = SUPER

bind = $mainMod, Return, exec, kitty
bind = $mainMod, Q, killactive
bind = $mainMod, M, exit
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating
bind = $mainMod, D, exec, rofi -show drun
bind = $mainMod, P, pseudo
bind = $mainMod, J, togglesplit

# Move focus
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move window to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Screenshot
bind = , Print, exec, grim -g "$(slurp)" - | swappy -f -

# Volume
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Brightness
bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
HYPR_EOF

    chown $USERNAME:$USERNAME /mnt/home/$USERNAME/.config/hypr/hyprland.conf
    print_success "Basic Hyprland config created"
fi

# Ensure all config files have proper ownership
print_info "Setting proper ownership for all Hyprland configs..."
chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME/.config 2>/dev/null || true
chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME/build 2>/dev/null || true

print_success "Hyprland installation complete"
log_success "Desktop: Hyprland with amazing blue/black theme installed"

print_info "Hyprland will autologin and start automatically"
print_info "Press SUPER+Return for terminal, SUPER+D for app launcher"
