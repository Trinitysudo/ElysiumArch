#!/usr/bin/env bash
#
# Module 10: Applications Installation
# Install user applications
#

print_info "Installing user applications..."

# Ensure multilib is enabled (required for Steam)
print_info "Verifying multilib repository is enabled..."
if ! grep -q "^\[multilib\]" /mnt/etc/pacman.conf; then
    print_warning "Multilib not enabled! Enabling now..."
    cat >> /mnt/etc/pacman.conf << 'MULTILIB_EOF'

[multilib]
Include = /etc/pacman.d/mirrorlist
MULTILIB_EOF
    print_success "Multilib repository enabled"
    arch-chroot /mnt pacman -Sy
else
    print_info "Multilib already enabled"
fi

# Install Steam and gaming support
print_info "Installing Steam and gaming support..."

# Base Steam packages
STEAM_PACKAGES="steam vulkan-icd-loader lib32-vulkan-icd-loader lib32-gcc-libs"

# Add GPU-specific 32-bit libs if not in VM
if ! systemd-detect-virt --quiet; then
    if lspci | grep -i nvidia &>/dev/null; then
        print_info "Adding NVIDIA 32-bit libraries for gaming..."
        STEAM_PACKAGES="$STEAM_PACKAGES lib32-nvidia-utils"
    elif lspci | grep -i amd &>/dev/null; then
        print_info "Adding AMD 32-bit libraries for gaming..."
        STEAM_PACKAGES="$STEAM_PACKAGES lib32-vulkan-radeon lib32-libva-mesa-driver lib32-mesa-vdpau"
    elif lspci | grep -i intel &>/dev/null; then
        print_info "Adding Intel 32-bit libraries for gaming..."
        STEAM_PACKAGES="$STEAM_PACKAGES lib32-vulkan-intel lib32-libva-intel-driver"
    fi
fi

arch-chroot /mnt pacman -S --noconfirm --needed $STEAM_PACKAGES

if [[ $? -eq 0 ]]; then
    print_success "Steam installed with GPU-specific libraries"
    echo "STEAM_SUCCESS" >> /mnt/var/log/elysium/install_status
else
    print_error "Steam installation failed!"
    log_error "Applications: Steam installation failed"
fi

# Install OBS Studio
print_info "Installing OBS Studio..."
arch-chroot /mnt pacman -S --noconfirm --needed obs-studio

print_success "OBS Studio installed"

# Install Kitty terminal + fastfetch (ChrisTitus style)
print_info "Installing Kitty terminal and fastfetch..."
arch-chroot /mnt pacman -S --noconfirm --needed kitty fastfetch

print_success "Kitty and fastfetch installed"

# Configure fastfetch to auto-run in Kitty
print_info "Configuring fastfetch auto-start..."
mkdir -p /mnt/home/$USERNAME/.config/kitty
mkdir -p /mnt/home/$USERNAME/.config/fastfetch

# Create beautiful Kitty config
cat > /mnt/home/$USERNAME/.config/kitty/kitty.conf << 'KITTY_EOF'
# ChrisTitus-style Kitty config
font_family      JetBrainsMono Nerd Font
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size 11.0

# Theme: Monokai (dark, beautiful)
background #1e1e1e
foreground #f8f8f2
cursor #f8f8f0

# Black
color0  #272822
color8  #75715e

# Red
color1  #f92672
color9  #f92672

# Green
color2  #a6e22e
color10 #a6e22e

# Yellow
color3  #f4bf75
color11 #f4bf75

# Blue
color4  #66d9ef
color12 #66d9ef

# Magenta
color5  #ae81ff
color13 #ae81ff

# Cyan
color6  #a1efe4
color14 #a1efe4

# White
color7  #f8f8f2
color15 #f9f8f5

# Window
window_padding_width 4
background_opacity 0.95
confirm_os_window_close 0

# Shell integration
shell_integration enabled

# Run fastfetch on startup
startup_session ~/.config/kitty/startup.conf
KITTY_EOF

# Create startup session for fastfetch
cat > /mnt/home/$USERNAME/.config/kitty/startup.conf << 'STARTUP_EOF'
launch sh -c "fastfetch; exec $SHELL"
STARTUP_EOF

# Create beautiful fastfetch config (ChrisTitus style)
cat > /mnt/home/$USERNAME/.config/fastfetch/config.jsonc << 'FASTFETCH_EOF'
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "auto",
    "padding": {
      "top": 1,
      "left": 2
    }
  },
  "display": {
    "separator": " → ",
    "color": {
      "keys": "blue",
      "title": "blue"
    }
  },
  "modules": [
    {
      "type": "title",
      "format": "{user-name-colored}@{host-name-colored}"
    },
    {
      "type": "separator",
      "string": "─"
    },
    {
      "type": "os",
      "key": " OS"
    },
    {
      "type": "kernel",
      "key": " Kernel"
    },
    {
      "type": "packages",
      "key": "󰏖 Packages"
    },
    {
      "type": "shell",
      "key": " Shell"
    },
    {
      "type": "de",
      "key": " DE"
    },
    {
      "type": "wm",
      "key": " WM"
    },
    {
      "type": "terminal",
      "key": " Terminal"
    },
    {
      "type": "cpu",
      "key": "󰻠 CPU"
    },
    {
      "type": "gpu",
      "key": "󰍛 GPU"
    },
    {
      "type": "memory",
      "key": "󰑭 Memory"
    },
    {
      "type": "disk",
      "key": " Disk"
    },
    {
      "type": "uptime",
      "key": "󰅐 Uptime"
    },
    {
      "type": "separator",
      "string": "─"
    },
    {
      "type": "colors",
      "symbol": "circle"
    }
  ]
}
FASTFETCH_EOF

chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME/.config/kitty
chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME/.config/fastfetch

print_success "Kitty terminal configured with fastfetch auto-start"

# Also add fastfetch to bash/zsh for other terminals
cat >> /mnt/home/$USERNAME/.bashrc << 'BASH_FASTFETCH'

# Run fastfetch on terminal startup (except in Kitty which handles it)
if [ -z "$KITTY_WINDOW_ID" ]; then
    if command -v fastfetch &>/dev/null; then
        fastfetch
    fi
fi
BASH_FASTFETCH

cat >> /mnt/home/$USERNAME/.zshrc << 'ZSH_FASTFETCH'

# Run fastfetch on terminal startup (except in Kitty which handles it)
if [ -z "$KITTY_WINDOW_ID" ]; then
    if command -v fastfetch &>/dev/null; then
        fastfetch
    fi
fi
ZSH_FASTFETCH

print_success "Fastfetch configured for all terminals"

# Install media players
print_info "Installing media players..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    vlc \
    mpv

print_success "Media players installed"

# Install image editing
print_info "Installing GIMP..."
arch-chroot /mnt pacman -S --noconfirm --needed gimp

print_success "GIMP installed"

# Install AUR applications (require yay)
print_info "Installing AUR applications..."

# Verify yay is available
if ! arch-chroot /mnt su - $USERNAME -c "command -v yay" &>/dev/null; then
    print_error "yay not found! Skipping AUR applications..."
    return 1
fi

# Install Visual Studio Code
print_info "Installing Visual Studio Code..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm --needed visual-studio-code-bin"

if [[ $? -eq 0 ]]; then
    print_success "VS Code installed"
else
    print_warning "Failed to install VS Code (optional)"
fi

# Install IntelliJ IDEA Community
print_info "Installing IntelliJ IDEA Community..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm --needed intellij-idea-community-edition"

if [[ $? -eq 0 ]]; then
    print_success "IntelliJ IDEA installed"
else
    print_warning "Failed to install IntelliJ IDEA (optional)"
fi

# Install Brave Browser
print_info "Installing Brave Browser..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm --needed brave-bin"

if [[ $? -eq 0 ]]; then
    print_success "Brave Browser installed"
else
    print_warning "Failed to install Brave (optional)"
fi

# Install Discord
print_info "Installing Discord..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm --needed discord"

if [[ $? -eq 0 ]]; then
    print_success "Discord installed"
else
    print_warning "Failed to install Discord (optional)"
fi

# Install Modrinth Launcher
print_info "Installing Modrinth Launcher..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm modrinth-app-bin"

if [[ $? -eq 0 ]]; then
    print_success "Modrinth Launcher installed"
else
    print_warning "Failed to install Modrinth (optional)"
fi

# Install Balena Etcher
print_info "Installing Balena Etcher..."
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm balena-etcher-bin"

if [[ $? -eq 0 ]]; then
    print_success "Balena Etcher installed"
else
    print_warning "Failed to install Balena Etcher (optional)"
fi

print_success "Applications installation complete"
log_success "Applications: All applications installed"
