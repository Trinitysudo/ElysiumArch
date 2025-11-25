# ElysiumArch Installation Guide

## 🚀 Quick Start - One Shot Installation

### Step 1: Boot Arch Linux ISO
1. Download latest Arch Linux ISO from https://archlinux.org/download/
2. Create bootable USB with Rufus (Windows) or `dd` (Linux)
3. Boot from USB in UEFI mode (disable Secure Boot if needed)

### Step 2: Connect to Internet
```bash
# For WiFi:
iwctl
station wlan0 connect "Your-WiFi-Name"
quit

# Test connection:
ping -c 3 archlinux.org
```

### Step 3: Download and Run Installer
```bash
# Download the installer
curl -L https://github.com/Trinitysudo/ElysiumArch/archive/main.zip -o elysium.zip
unzip elysium.zip
cd ElysiumArch-main

# Make executable and run
chmod +x install.sh
./install.sh
```

## 📝 What You'll Be Asked

The installer will ask for:

1. **Username** - Your login name (lowercase, no spaces)
2. **Password** - ONE password for both your account AND root (simplified!)
3. **Disk Selection** - Which disk to install on (auto-selected if only one disk)
4. **Partition Scheme** - Full disk or with swap (default: no swap)

That's it! The rest is automatic.

## ⚙️ What Gets Installed

### Desktop Environment
- **Hyprland** - Tiling Wayland compositor
- **ML4W Dotfiles** - Professional pre-configured setup by mylinuxforwork
- **TTY Autologin** - Boots directly to Hyprland (no display manager)

### System Components
- Waybar (status bar)
- Rofi (app launcher)
- Dunst (notifications)
- Kitty (terminal with ChrisTitus mybash)
- Thunar (file manager)

### Development Tools
- Java OpenJDK 17 & 21
- Maven & Gradle
- Visual Studio Code
- IntelliJ IDEA Community
- Node.js & npm

### Applications
- Brave Browser
- Discord
- Steam
- OBS Studio
- VLC Media Player
- Kate (text editor)
- fastfetch

### System Utilities
- yay & paru (AUR helpers)
- Homebrew (optional package manager)
- Timeshift (backups)
- btop (system monitor)
- NetworkManager (with applet)
- Bluetooth (bluez + blueman)
- PipeWire (audio)

### Security
- UFW Firewall (enabled)
- Fail2Ban
- AppArmor
- System auditing

## 🎮 GPU Support

### NVIDIA (RTX 3060 Optimized)
- Latest NVIDIA drivers
- Wayland support configured
- Hardware acceleration enabled
- Global environment variables set

### VM Detection
- Automatic VM detection
- Software rendering for VMs
- Works in VirtualBox, VMware, QEMU/KVM

### AMD & Intel
- Mesa drivers
- Vulkan support
- Hardware acceleration

## 🔧 Post-Installation

### First Boot
1. System boots to TTY1
2. Auto-login to your account
3. Hyprland starts automatically with ML4W config

### Keybindings (ML4W Defaults)
- `Super + Return` - Open terminal (Kitty)
- `Super + Q` - Close window
- `Super + D` - App launcher (Rofi)
- `Super + F` - Toggle fullscreen
- `Super + M` - Exit Hyprland
- `Super + Shift + R` - Reload Hyprland

### Update System
```bash
yay -Syu
```

### Create Backup
```bash
sudo timeshift --create --comments "Fresh Install"
```

### Customize ML4W
```bash
# ML4W provides a settings app
ml4w-settings

# Or edit configs manually
~/.config/hypr/hyprland.conf
~/.config/waybar/config
```

## 🔍 Troubleshooting

### Installation Failed?
The installer has checkpoint system - just run `./install.sh` again and it will resume from where it failed!

### Hyprland Won't Start?
Check logs:
```bash
journalctl -xe
cat ~/.local/share/hyprland/hyprland.log
```

### No Internet After Install?
```bash
sudo systemctl enable --now NetworkManager
nmtui
```

### NVIDIA Issues?
Check driver installation:
```bash
nvidia-smi
cat /etc/modprobe.d/nvidia.conf
```

## 📦 Package Managers

### yay (Default AUR Helper)
```bash
yay -S package-name
yay -Syu  # Update all packages
yay -Rns package-name  # Remove package
```

### paru (Alternative AUR Helper)
```bash
paru -S package-name
```

### Homebrew (Optional)
```bash
brew install package-name
```

## 🎨 Theming

All theming is handled by **ML4W Dotfiles**. No custom configs applied!

- Professional Waybar themes
- Beautiful Rofi themes
- Curated wallpapers
- GTK theme integration
- Complete color schemes

## 🆘 Support

- GitHub Issues: https://github.com/Trinitysudo/ElysiumArch/issues
- ML4W Docs: https://mylinuxforwork.github.io/dotfiles/
- Arch Wiki: https://wiki.archlinux.org/
- Hyprland Wiki: https://wiki.hyprland.org/

## 📜 License

MIT License - See LICENSE file for details

---

**Made with ❤️ for the Arch Linux community**

*"LOWK FUCK GNOME" - The Philosophy Behind ElysiumArch*
