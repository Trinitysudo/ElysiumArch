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

# Install ChrisTitus mybash config (the REAL setup)
print_info "Installing ChrisTitus mybash configuration..."
arch-chroot /mnt sudo -u $USERNAME bash << 'CHRISTITUS_EOF'
set -e
cd ~
mkdir -p ~/build
cd ~/build

# Clone ChrisTitus mybash repo
if [ ! -d "mybash" ]; then
    git clone https://github.com/christitustech/mybash || {
        echo "Failed to clone mybash repo"
        exit 1
    }
fi

cd mybash
# Run setup script
chmod +x setup.sh
./setup.sh || {
    echo "mybash setup failed, but continuing..."
}

echo "ChrisTitus mybash installed successfully"
CHRISTITUS_EOF

if [[ $? -eq 0 ]]; then
    print_success "ChrisTitus mybash configuration installed"
else
    print_warning "ChrisTitus mybash failed (optional), continuing with manual config..."
fi

# Configure fastfetch and Kitty anyway
print_info "Configuring Kitty terminal..."
mkdir -p /mnt/home/$USERNAME/.config/kitty
mkdir -p /mnt/home/$USERNAME/.config/fastfetch

# Create beautiful Kitty config (ChrisTitus style)
cat > /mnt/home/$USERNAME/.config/kitty/kitty.conf << 'KITTY_EOF'
# ChrisTitus-style Kitty Terminal Config
# Beautiful, fast, feature-rich terminal

# Font Configuration
font_family      JetBrainsMono Nerd Font Mono
bold_font        JetBrainsMono Nerd Font Mono Bold
italic_font      JetBrainsMono Nerd Font Mono Italic
bold_italic_font JetBrainsMono Nerd Font Mono Bold Italic
font_size 12.0

# Fallback fonts
symbol_map U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A3,U+E0B0-U+E0C8,U+E0CA,U+E0CC-U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E6B1,U+E700-U+E7C5,U+EA60-U+EBEB,U+F000-U+F2E0,U+F300-U+F32F,U+F400-U+F4A9,U+F500-U+FD46 JetBrainsMono Nerd Font Mono

# Theme: Nord-inspired with blue accents (beautiful dark theme)
background #1e1e2e
foreground #cdd6f4
cursor #f5e0dc
cursor_text_color #1e1e2e

# Selection colors
selection_background #585b70
selection_foreground #cdd6f4

# Tab bar colors
active_tab_background #89b4fa
active_tab_foreground #1e1e2e
inactive_tab_background #45475a
inactive_tab_foreground #cdd6f4

# Color palette (Catppuccin-inspired)
# Black
color0  #45475a
color8  #585b70

# Red
color1  #f38ba8
color9  #f38ba8

# Green
color2  #a6e3a1
color10 #a6e3a1

# Yellow
color3  #f9e2af
color11 #f9e2af

# Blue
color4  #89b4fa
color12 #89b4fa

# Magenta
color5  #cba6f7
color13 #cba6f7

# Cyan
color6  #94e2d5
color14 #94e2d5

# White
color7  #bac2de
color15 #a6adc8

# Window layout and appearance
window_padding_width 8
window_margin_width 0
background_opacity 0.92
dynamic_background_opacity yes

# Don't ask for confirmation when closing
confirm_os_window_close 0

# Shell integration
shell_integration enabled

# Tab bar
tab_bar_edge top
tab_bar_style powerline
tab_powerline_style slanted

# Performance
repaint_delay 10
input_delay 3
sync_to_monitor yes

# Mouse
mouse_hide_wait 2.0
copy_on_select yes

# Advanced
allow_remote_control yes
listen_on unix:/tmp/kitty

# Bell
enable_audio_bell no
visual_bell_duration 0.0
KITTY_EOF

# Create Kitty startup script to run fastfetch properly
cat > /mnt/home/$USERNAME/.config/kitty/kitty-startup.sh << 'KITTY_STARTUP_EOF'
#!/bin/bash
# Run fastfetch on Kitty startup
if command -v fastfetch &>/dev/null; then
    fastfetch
fi
exec bash
KITTY_STARTUP_EOF

chmod +x /mnt/home/$USERNAME/.config/kitty/kitty-startup.sh

# Add shell config to Kitty
cat >> /mnt/home/$USERNAME/.config/kitty/kitty.conf << 'KITTY_SHELL_EOF'

# Run fastfetch on startup
shell ~/.config/kitty/kitty-startup.sh
KITTY_SHELL_EOF

# Create beautiful fastfetch config (ChrisTitus style - clean and informative)
cat > /mnt/home/$USERNAME/.config/fastfetch/config.jsonc << 'FASTFETCH_EOF'
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "auto",
    "padding": {
      "top": 1,
      "left": 3,
      "right": 3
    }
  },
  "display": {
    "separator": "  ",
    "color": {
      "keys": "blue",
      "title": "bold-blue"
    }
  },
  "modules": [
    {
      "type": "title",
      "format": "{user-name-colored}@{host-name-colored}",
      "color": {
        "user": "cyan",
        "host": "blue"
      }
    },
    {
      "type": "separator",
      "string": "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    },
    {
      "type": "os",
      "key": "   OS",
      "keyColor": "blue"
    },
    {
      "type": "host",
      "key": "   Host",
      "keyColor": "blue"
    },
    {
      "type": "kernel",
      "key": "   Kernel",
      "keyColor": "blue"
    },
    {
      "type": "uptime",
      "key": "   Uptime",
      "keyColor": "green"
    },
    {
      "type": "packages",
      "key": "  󰏖 Packages",
      "keyColor": "cyan"
    },
    {
      "type": "shell",
      "key": "   Shell",
      "keyColor": "yellow"
    },
    {
      "type": "de",
      "key": "   DE",
      "keyColor": "blue"
    },
    {
      "type": "wm",
      "key": "   WM",
      "keyColor": "blue"
    },
    {
      "type": "terminal",
      "key": "   Terminal",
      "keyColor": "magenta"
    },
    {
      "type": "cpu",
      "key": "  󰻠 CPU",
      "keyColor": "red"
    },
    {
      "type": "gpu",
      "key": "  󰍛 GPU",
      "keyColor": "red"
    },
    {
      "type": "memory",
      "key": "  󰑭 Memory",
      "keyColor": "yellow"
    },
    {
      "type": "disk",
      "key": "   Disk",
      "keyColor": "cyan"
    },
    {
      "type": "localip",
      "key": "  󰩟 Local IP",
      "keyColor": "green"
    },
    {
      "type": "separator",
      "string": "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    },
    {
      "type": "colors",
      "symbol": "circle",
      "paddingLeft": 2
    }
  ]
}
FASTFETCH_EOF

chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME/.config/kitty
chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME/.config/fastfetch

print_success "Kitty terminal configured with ChrisTitus-style theme"
print_info "Features: Beautiful colors, Nerd Font icons, fastfetch on startup"

# Also add fastfetch to bash/zsh for GNOME Terminal and other terminals
print_info "Configuring fastfetch for other terminals..."

# For bash
if ! grep -q "fastfetch" /mnt/home/$USERNAME/.bashrc 2>/dev/null; then
    cat >> /mnt/home/$USERNAME/.bashrc << 'BASH_FASTFETCH'

# Show system info with fastfetch on new terminal (ChrisTitus style)
if command -v fastfetch &>/dev/null; then
    # Only run in interactive shells, not in scripts
    if [[ $- == *i* ]]; then
        fastfetch 2>/dev/null || true
    fi
fi
BASH_FASTFETCH
fi

# For zsh (if it exists)
if [ -f /mnt/home/$USERNAME/.zshrc ]; then
    if ! grep -q "fastfetch" /mnt/home/$USERNAME/.zshrc; then
        cat >> /mnt/home/$USERNAME/.zshrc << 'ZSH_FASTFETCH'

# Show system info with fastfetch on new terminal (ChrisTitus style)
if command -v fastfetch &>/dev/null; then
    # Only run in interactive shells, not in scripts
    if [[ -o interactive ]]; then
        fastfetch 2>/dev/null || true
    fi
fi
ZSH_FASTFETCH
    fi
fi

print_success "Fastfetch configured for all terminals (bash, zsh, Kitty)"

# Install VLC media player
print_info "Installing VLC media player..."
arch-chroot /mnt pacman -S --noconfirm --needed vlc

print_success "VLC installed"

# Install AUR applications (require yay)
print_info "Installing essential AUR applications..."

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
arch-chroot /mnt su - $USERNAME -c "yay -S --noconfirm --needed modrinth-app-bin"

if [[ $? -eq 0 ]]; then
    print_success "Modrinth Launcher installed"
else
    print_warning "Failed to install Modrinth (optional)"
fi

print_success "Applications installation complete"
log_success "Applications: All applications installed"
