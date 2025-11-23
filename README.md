# 🌟 ElysiumArch - Automated Arch Linux Installer

<div align="center">

![ElysiumArch](https://img.shields.io/badge/Arch-Linux-1793D1?logo=arch-linux&logoColor=fff)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Status](https://img.shields.io/badge/status-active-success.svg)

**A fully automated, bare-bones Arch Linux installer optimized for Java development with GNOME desktop**

</div>

---

## 📋 Overview

**ElysiumArch** is an intelligent, automated Arch Linux installer that sets up a complete development environment with a single command. Inspired by Chris Titus Tech's approach, this installer handles everything from network configuration to desktop theming automatically.

### 🎯 Target System Specs
- **CPU:** AMD Ryzen 5700X
- **GPU:** NVIDIA RTX 3060
- **RAM:** 16GB
- **Storage:** 500GB NVME SSD
- **Use Case:** Java Development & Gaming

---

## ✨ Features

### 🔧 **Core System**
- ✅ Full Arch Linux base installation
- ✅ GRUB bootloader with auto-configuration
- ✅ Auto disk partitioning with safety confirmations
- ✅ Multi-display support (optimized for 2 monitors)
- ✅ Timeshift for system snapshots and backups

### 🖥️ **Desktop Environment**
- ✅ GNOME (latest) with GDM login manager
- ✅ Wayland, X11, and XWayland support
- ✅ Dark theme with blue accent colors
- ✅ Komorebi live wallpaper engine
- ✅ Premium GNOME extensions pre-configured
- ✅ Icon themes and customization

### 🎮 **Graphics & Performance**
- ✅ NVIDIA proprietary drivers (optimized for RTX 3060)
- ✅ Hardware acceleration for Wayland
- ✅ Vulkan support for gaming
- ✅ Multi-monitor configuration tools

### 📦 **Package Managers**
- ✅ **yay** - AUR helper (primary)
- ✅ **paru** - Alternative AUR helper
- ✅ **Homebrew** - Cross-platform package manager
- ✅ **pacman** - Official Arch package manager

### 💻 **Development Tools**
- ✅ **Visual Studio Code** - Primary IDE
- ✅ **IntelliJ IDEA Community** - Java IDE
- ✅ **Java OpenJDK 17 & 21** - Multiple Java versions
- ✅ **Node.js & npm** - JavaScript runtime
- ✅ **Git** - Version control
- ✅ **Docker** (optional)

### 🌐 **Applications**
- ✅ **Brave Browser** - Privacy-focused browser
- ✅ **Discord** - Communication platform
- ✅ **Steam** - Gaming platform with Proton
- ✅ **OBS Studio** - Streaming and recording
- ✅ **Modrinth Launcher** - Minecraft launcher
- ✅ **Balena Etcher** - USB image writer
- ✅ **App Store** - GNOME Software Center

### 🛠️ **Utilities**
- ✅ **Kitty** - Modern GPU-accelerated terminal
- ✅ **Chris Titus Terminal Config** - Enhanced shell experience
- ✅ **Kate** - Advanced text editor
- ✅ **GNOME Tweaks** - System customization
- ✅ **fastfetch** - System information tool
- ✅ **7-Zip / p7zip** - Archive management
- ✅ **unrar** - RAR extraction
- ✅ **file-roller** - GNOME archive manager

### 🎨 **Theming & Customization**
- ✅ System-wide dark theme
- ✅ Blue accent colors
- ✅ Custom icon packs (Papirus, Tela)
- ✅ Live animated wallpapers (Komorebi)
- ✅ Custom login screen
- ✅ Shell themes and extensions

---

## 🚀 Installation

### Prerequisites
1. Boot into **Arch Linux ISO** (latest)
2. Ensure you have internet connectivity
3. Have your NVME drive ready (will be formatted)

### Quick Start

```bash
# 1. Connect to the internet (if not already connected)
#    WiFi: The installer will guide you
#    Ethernet: Should work automatically

# 2. Download the installer
curl -L https://github.com/Trinitysudo/ElysiumArch/archive/main.tar.gz | tar xz
cd ElysiumArch-main

# 3. Make the installer executable
chmod +x install.sh

# 4. Run the installer
./install.sh
```

### Alternative: Clone with Git

```bash
# If git is available on your ISO
git clone https://github.com/Trinitysudo/ElysiumArch.git
cd ElysiumArch
chmod +x install.sh
./install.sh
```

---

## 📖 Installation Process Flow

The installer follows this automated workflow:

### **Phase 1: Pre-Installation** (5-10 minutes)
1. **Welcome Screen** - Display banner and system check
2. **Network Configuration**
   - Auto-detect ethernet connection
   - WiFi setup wizard if needed (interactive)
3. **Localization**
   - Select language (default: English)
   - Choose timezone
   - Configure keyboard layout
4. **Disk Selection**
   - List available drives
   - Select installation target (NVME)
   - Confirm disk wipe (safety prompt)

### **Phase 2: Disk Setup** (2-5 minutes)
5. **Partitioning**
   - 512MB EFI partition
   - 4GB Swap partition
   - Remaining space for root (/)
6. **Formatting**
   - Format EFI as FAT32
   - Format root as ext4
   - Create and enable swap
7. **Mounting**
   - Mount filesystems
   - Verify mount points

### **Phase 3: Base System** (10-15 minutes)
8. **Install Base Packages**
   - linux, linux-firmware, base, base-devel
   - Essential system utilities
9. **Configure System**
   - Generate fstab
   - Set timezone and locale
   - Configure hostname
10. **Install Bootloader**
    - Install GRUB for UEFI
    - Generate GRUB config
    - Configure boot options

### **Phase 4: Display Server & Desktop** (15-20 minutes)
11. **Install Graphics Drivers**
    - NVIDIA proprietary drivers
    - Vulkan support
    - CUDA toolkit (for development)
12. **Install GNOME**
    - GNOME desktop environment
    - GDM display manager
    - Wayland/X11/XWayland support
13. **Enable Services**
    - NetworkManager
    - GDM (auto-start GUI)

### **Phase 5: Package Managers** (5-10 minutes)
14. **Install AUR Helpers**
    - yay (primary)
    - paru (alternative)
15. **Install Homebrew**
    - Linux Homebrew setup
    - Add to PATH

### **Phase 6: Development Environment** (20-30 minutes)
16. **Install Java Development Tools**
    - OpenJDK 17 & 21
    - Set Java 17 as default
    - Configure JAVA_HOME
17. **Install IDEs**
    - Visual Studio Code
    - IntelliJ IDEA Community Edition
18. **Install Node.js & Tools**
    - Node.js (LTS)
    - npm, yarn
    - Essential global packages

### **Phase 7: Applications** (30-40 minutes)
19. **Install Web Browser**
    - Brave Browser
20. **Install Communication**
    - Discord
21. **Install Gaming**
    - Steam with Proton
    - Modrinth Launcher
22. **Install Content Creation**
    - OBS Studio
23. **Install Utilities**
    - Balena Etcher
    - GNOME Software (App Store)
    - Timeshift
    - fastfetch
    - Archive tools (7-zip, unrar)
24. **Install Editors & Terminals**
    - Kate text editor
    - Kitty terminal
    - Chris Titus terminal config

### **Phase 8: Theming & Customization** (10-15 minutes)
25. **Apply System Theme**
    - Dark mode activation
    - Blue accent colors
    - Icon themes (Papirus, Tela)
26. **Install GNOME Extensions**
    - User Themes
    - Dash to Dock
    - Arc Menu
    - Blur My Shell
    - Just Perfection
27. **Setup Live Wallpapers**
    - Install Komorebi
    - Configure default wallpaper
28. **Customize Login Screen**
    - GDM theme modifications
    - Background image

### **Phase 9: Post-Installation** (5-10 minutes)
29. **System Optimization**
    - Enable multilib repository
    - Configure pacman (parallel downloads, colors)
    - Set up Timeshift snapshots
30. **Multi-Monitor Setup**
    - Detect displays
    - Configure layout
    - Save configuration
31. **Final Touches**
    - Create user-specific configs
    - Set default applications
    - Generate system information
32. **Cleanup**
    - Remove unnecessary packages
    - Clear package cache (partial)
33. **Reboot Prompt**
    - Display completion summary
    - Prompt for system reboot

---

## 🗂️ Project Structure

```
ElysiumArch/
├── install.sh                      # Main installer script (entry point)
│
├── modules/                        # Modular installation scripts
│   ├── 01-network.sh              # WiFi/Ethernet configuration
│   ├── 02-localization.sh         # Language, timezone, keyboard
│   ├── 03-disk.sh                 # Disk selection and partitioning
│   ├── 04-base-system.sh          # Base Arch installation
│   ├── 05-bootloader.sh           # GRUB installation and config
│   ├── 06-nvidia-drivers.sh       # NVIDIA driver installation
│   ├── 07-desktop-environment.sh  # GNOME installation
│   ├── 08-package-managers.sh     # yay, paru, homebrew
│   ├── 09-development-tools.sh    # Java, Node, IDEs
│   ├── 10-applications.sh         # All user applications
│   ├── 11-utilities.sh            # Terminal, editors, tools
│   ├── 12-theming.sh              # Themes, icons, wallpapers
│   ├── 13-gnome-extensions.sh     # GNOME extensions
│   └── 14-post-install.sh         # Final configuration and cleanup
│
├── configs/                        # Configuration files and templates
│   ├── grub/
│   │   └── grub.conf              # GRUB bootloader configuration
│   ├── gnome/
│   │   ├── settings.ini           # GNOME default settings
│   │   ├── extensions.txt         # List of GNOME extensions
│   │   └── keybindings.conf       # Custom keyboard shortcuts
│   ├── nvidia/
│   │   ├── xorg.conf              # X11 NVIDIA configuration
│   │   └── nvidia.conf            # Kernel module options
│   ├── shell/
│   │   ├── .bashrc                # Bash configuration
│   │   ├── .zshrc                 # Zsh configuration (Chris Titus style)
│   │   └── starship.toml          # Starship prompt config
│   ├── kitty/
│   │   └── kitty.conf             # Kitty terminal configuration
│   ├── vscode/
│   │   ├── settings.json          # VSCode settings
│   │   └── extensions.txt         # VSCode extensions list
│   ├── timeshift/
│   │   └── timeshift.json         # Timeshift backup schedule
│   └── pacman/
│       └── pacman.conf            # Pacman configuration (colors, parallel downloads)
│
├── assets/                         # Assets and resources
│   ├── wallpapers/                # Default wallpapers
│   │   ├── elysium-default.jpg
│   │   └── live-wallpapers/       # Komorebi wallpaper packs
│   ├── themes/                    # Custom themes
│   │   └── elysium-blue/          # Blue accent theme
│   ├── icons/                     # Icon theme
│   └── fonts/                     # Custom fonts (optional)
│
├── scripts/                        # Helper scripts
│   ├── helpers.sh                 # Shared utility functions
│   ├── logger.sh                  # Logging functionality
│   ├── ui.sh                      # User interface functions (menus, prompts)
│   ├── network-setup.sh           # Network connection wizard
│   ├── disk-wizard.sh             # Interactive disk selection
│   └── post-reboot.sh             # Run after first reboot (user setup)
│
├── packages/                       # Package lists
│   ├── base-packages.txt          # Base system packages
│   ├── desktop-packages.txt       # GNOME and desktop packages
│   ├── development-packages.txt   # Development tools
│   ├── application-packages.txt   # User applications
│   ├── aur-packages.txt           # AUR packages (via yay/paru)
│   └── optional-packages.txt      # Optional/suggested packages
│
├── logs/                           # Installation logs (created during install)
│   └── .gitkeep
│
├── tests/                          # Testing scripts (optional)
│   └── vm-test.sh                 # Test installer in VM
│
├── docs/                           # Additional documentation
│   ├── TROUBLESHOOTING.md         # Common issues and solutions
│   ├── CUSTOMIZATION.md           # How to customize the installer
│   ├── PACKAGE-LIST.md            # Complete list of installed packages
│   └── FAQ.md                     # Frequently asked questions
│
├── .gitignore                      # Git ignore file
├── LICENSE                         # MIT License
└── README.md                       # This file
```

---

## 📊 Detailed Component Breakdown

### **Main Entry Point: `install.sh`**
- Displays welcome banner (ASCII art "ElysiumArch")
- Performs system checks (internet, UEFI mode, RAM)
- Sources all helper functions from `scripts/`
- Calls all modules in sequence from `modules/`
- Handles errors and logs everything to `logs/install.log`
- Provides progress indicators for each phase
- Final reboot prompt with summary

### **Modules Directory** (`modules/`)

#### `01-network.sh`
- Auto-detects ethernet connection
- WiFi wizard using `iwctl` for wireless setup
- Tests internet connectivity (ping archlinux.org)
- Syncs system clock with NTP

#### `02-localization.sh`
- Interactive menu for language selection
- Timezone selection (auto-detect or manual)
- Keyboard layout configuration
- Generates locale settings

#### `03-disk.sh`
- Lists all available disks with size info
- User selects target disk (e.g., /dev/nvme0n1)
- Triple confirmation before disk wipe
- Auto-partitioning scheme:
  - `/dev/nvme0n1p1` - 512MB EFI
  - `/dev/nvme0n1p2` - 4GB Swap
  - `/dev/nvme0n1p3` - Remaining (root)
- Formats and mounts partitions

#### `04-base-system.sh`
- Installs base packages using `pacstrap`
- Generates fstab
- Chroots into new system
- Sets hostname to "elysium-arch"
- Creates initial user account
- Configures sudo access

#### `05-bootloader.sh`
- Installs GRUB for UEFI systems
- Installs `os-prober` for dual-boot detection
- Generates GRUB configuration
- Installs CPU microcode (AMD)

#### `06-nvidia-drivers.sh`
- Installs NVIDIA proprietary drivers
- Installs CUDA toolkit (for NVIDIA compute)
- Configures Xorg for NVIDIA
- Sets up kernel module early loading
- Enables hardware acceleration

#### `07-desktop-environment.sh`
- Installs GNOME (full group)
- Installs GDM display manager
- Enables Wayland, X11, and XWayland sessions
- Enables NetworkManager
- Enables GDM service (auto-start GUI)
- Installs GNOME Tweaks

#### `08-package-managers.sh`
- Installs yay (AUR helper) from AUR
- Installs paru (alternative AUR helper)
- Installs Homebrew on Linux
- Configures yay for optimal use

#### `09-development-tools.sh`
- Installs OpenJDK 17 and 21
- Sets Java 17 as default with `archlinux-java`
- Installs Visual Studio Code (from AUR)
- Installs IntelliJ IDEA Community
- Installs Node.js and npm
- Installs Git with configuration
- Installs development utilities (make, cmake, gcc, etc.)

#### `10-applications.sh`
- Installs Brave Browser (from AUR)
- Installs Discord (flatpak or AUR)
- Installs Steam with Proton support
- Installs Modrinth Launcher (AUR)
- Installs OBS Studio
- Installs Balena Etcher
- Installs GNOME Software (App Store)

#### `11-utilities.sh`
- Installs Timeshift (backup tool)
- Installs fastfetch (system info)
- Installs Kitty terminal
- Installs Kate editor
- Installs p7zip, unrar, file-roller (archive tools)
- Installs Chris Titus shell configuration
- Installs additional CLI tools (htop, neofetch, etc.)

#### `12-theming.sh`
- Enables dark theme via gsettings
- Sets blue accent color
- Installs icon themes (Papirus, Tela)
- Installs GTK themes (Orchis, Catppuccin)
- Installs Komorebi (live wallpaper engine)
- Sets default wallpaper from `assets/`
- Customizes GDM login screen

#### `13-gnome-extensions.sh`
- Installs GNOME Extensions app
- Installs extensions from `configs/gnome/extensions.txt`:
  - User Themes
  - Dash to Dock
  - Arc Menu
  - Blur My Shell
  - Just Perfection
  - Clipboard Indicator
  - Vitals (system monitor)
- Enables extensions by default

#### `14-post-install.sh`
- Enables multilib repository in `/etc/pacman.conf`
- Configures pacman (parallel downloads, colors, candy)
- Sets up Timeshift automatic snapshots
- Configures multi-monitor setup (xrandr/GNOME Displays)
- Sets default applications (browser, terminal, editor)
- Copies all config files from `configs/` to appropriate locations
- Cleans package cache (keeps recent versions)
- Generates final system report
- Creates post-reboot script for user-specific setup

### **Configs Directory** (`configs/`)
Contains all configuration files that will be copied to the system:
- Pre-configured settings for all installed applications
- GNOME desktop settings (dark theme, extensions, keybindings)
- Shell configurations (bash/zsh with Chris Titus optimizations)
- NVIDIA-specific X11 configurations
- Optimized pacman configuration
- Timeshift backup schedule

### **Scripts Directory** (`scripts/`)

#### `helpers.sh`
- Common functions used across all modules
- Functions: `print_info()`, `print_success()`, `print_error()`
- Package installation wrappers
- System detection utilities

#### `logger.sh`
- Centralized logging system
- Writes all output to `logs/install.log`
- Timestamps all log entries
- Error tracking and reporting

#### `ui.sh`
- Menu system using `dialog` or `whiptail`
- Progress bars for long operations
- Confirmation prompts
- Interactive selection menus

#### `network-setup.sh`
- Standalone WiFi setup wizard
- Can be called independently if needed
- Supports WPA/WPA2/WPA3 networks

#### `disk-wizard.sh`
- Interactive disk selection with safety checks
- Shows disk info (model, size, partitions)
- Partition scheme visualization
- Confirmation dialogs with clear warnings

#### `post-reboot.sh`
- Runs automatically after first login
- User-specific configurations
- Installs user-level packages
- Applies user theme preferences
- Final system checks

### **Packages Directory** (`packages/`)
Text files containing package lists for easy modification:
- Each line is one package name
- Comments supported with `#`
- Easy to customize before installation
- Separated by category for clarity

### **Assets Directory** (`assets/`)
- Default wallpapers (high-resolution)
- Live wallpaper packs for Komorebi
- Custom theme files (if not using AUR versions)
- Icon themes (if bundled)
- Optional fonts for better UI

---

## 🔄 Installation Flow Diagram

```
[Boot Arch ISO]
      ↓
[Download ElysiumArch from GitHub]
      ↓
[Run install.sh]
      ↓
┌─────────────────────────────────────┐
│   PHASE 1: PRE-INSTALLATION         │
├─────────────────────────────────────┤
│ ✓ Welcome & System Check            │
│ ✓ Network Configuration (WiFi/Eth)  │
│ ✓ Language & Timezone Selection     │
│ ✓ Keyboard Layout                   │
│ ✓ Disk Selection & Confirmation     │
└─────────────────────────────────────┘
      ↓
┌─────────────────────────────────────┐
│   PHASE 2: DISK SETUP               │
├─────────────────────────────────────┤
│ ✓ Partition Disk (EFI/Swap/Root)    │
│ ✓ Format Partitions                 │
│ ✓ Mount Filesystems                 │
└─────────────────────────────────────┘
      ↓
┌─────────────────────────────────────┐
│   PHASE 3: BASE SYSTEM              │
├─────────────────────────────────────┤
│ ✓ Install Base Packages             │
│ ✓ Generate fstab                    │
│ ✓ Configure System (locale/hostname)│
│ ✓ Install & Configure GRUB          │
│ ✓ Create User Account               │
└─────────────────────────────────────┘
      ↓
┌─────────────────────────────────────┐
│   PHASE 4: GRAPHICS & DESKTOP       │
├─────────────────────────────────────┤
│ ✓ Install NVIDIA Drivers             │
│ ✓ Install GNOME Desktop             │
│ ✓ Enable GDM (Display Manager)      │
│ ✓ Configure Wayland/X11/XWayland    │
└─────────────────────────────────────┘
      ↓
┌─────────────────────────────────────┐
│   PHASE 5: PACKAGE MANAGERS         │
├─────────────────────────────────────┤
│ ✓ Install yay (AUR Helper)          │
│ ✓ Install paru (Alternative)        │
│ ✓ Install Homebrew                  │
└─────────────────────────────────────┘
      ↓
┌─────────────────────────────────────┐
│   PHASE 6: DEVELOPMENT TOOLS        │
├─────────────────────────────────────┤
│ ✓ Install Java JDK 17 & 21          │
│ ✓ Install Visual Studio Code        │
│ ✓ Install IntelliJ IDEA              │
│ ✓ Install Node.js & npm             │
│ ✓ Configure Git                     │
└─────────────────────────────────────┘
      ↓
┌─────────────────────────────────────┐
│   PHASE 7: APPLICATIONS             │
├─────────────────────────────────────┤
│ ✓ Brave Browser                     │
│ ✓ Discord                           │
│ ✓ Steam (with Proton)               │
│ ✓ Modrinth Launcher                 │
│ ✓ OBS Studio                        │
│ ✓ Balena Etcher                     │
│ ✓ Utilities (Timeshift, fastfetch)  │
│ ✓ Terminals (Kitty)                 │
│ ✓ Editors (Kate)                    │
│ ✓ Archive Tools (7-zip, unrar)      │
└─────────────────────────────────────┘
      ↓
┌─────────────────────────────────────┐
│   PHASE 8: THEMING & CUSTOMIZATION  │
├─────────────────────────────────────┤
│ ✓ Apply Dark Theme + Blue Accent    │
│ ✓ Install Icon Themes               │
│ ✓ Install GNOME Extensions          │
│ ✓ Setup Komorebi (Live Wallpapers)  │
│ ✓ Customize Login Screen            │
│ ✓ Apply Chris Titus Shell Config    │
└─────────────────────────────────────┘
      ↓
┌─────────────────────────────────────┐
│   PHASE 9: POST-INSTALLATION        │
├─────────────────────────────────────┤
│ ✓ Enable Multilib Repository        │
│ ✓ Optimize Pacman                   │
│ ✓ Configure Timeshift Backups       │
│ ✓ Setup Multi-Monitor Support       │
│ ✓ Set Default Applications          │
│ ✓ Copy All Configs                  │
│ ✓ Cleanup & Generate Report         │
└─────────────────────────────────────┘
      ↓
[Display Summary & Reboot Prompt]
      ↓
[Reboot into ElysiumArch]
      ↓
[Auto-Login to GNOME Desktop]
      ↓
[Post-Reboot Script Runs]
      ↓
[COMPLETE! 🎉]
```

---

## 🎨 Additional Features & Suggestions

### **Performance Optimizations**
1. **Preload** - Application preloader for faster startup times
2. **irqbalance** - Better CPU interrupt distribution
3. **gamemode** - Optimize system for gaming performance
4. **cpupower** - CPU frequency scaling management
5. **TLP** - Advanced power management (for laptops, optional)
6. **earlyoom** - Out-of-memory killer to prevent freezes

### **Security Enhancements**
1. **ufw** (Uncomplicated Firewall) - Easy firewall management
2. **fail2ban** - Intrusion prevention system
3. **rkhunter** - Rootkit detection
4. **ClamAV** - Antivirus (optional)
5. **AppArmor** - Mandatory Access Control

### **Backup & Recovery**
1. **Timeshift** - System snapshots (already included)
2. **rsync** - Efficient file backup
3. **Déjà Dup** - GNOME backup tool
4. **BTRFS snapshots** - Filesystem-level snapshots (alternative to ext4)

### **Multimedia**
1. **VLC** - Media player
2. **GIMP** - Image editing
3. **Kdenlive** - Video editing
4. **Audacity** - Audio editing
5. **Blender** - 3D creation suite
6. **mpv** - Minimal media player
7. **Spotify** - Music streaming

### **Communication & Productivity**
1. **Thunderbird** - Email client
2. **LibreOffice** - Office suite
3. **Slack** - Team communication
4. **Zoom** - Video conferencing
5. **Notion** (web app) - Note-taking
6. **Obsidian** - Markdown notes

### **System Monitoring**
1. **htop** / **btop** - Process monitoring
2. **iotop** - Disk I/O monitoring
3. **nethogs** - Network bandwidth monitoring
4. **nvtop** - NVIDIA GPU monitoring
5. **GreenWithEnvy** - NVIDIA overclocking GUI
6. **GNOME System Monitor** - GUI resource monitor

### **File Management**
1. **Nautilus** (default GNOME Files)
2. **Nemo** - Alternative file manager
3. **Double Commander** - Two-panel file manager
4. **Syncthing** - File synchronization
5. **rclone** - Cloud storage sync

### **Terminal Enhancements**
1. **zsh** with **Oh-My-Zsh** - Enhanced shell (Chris Titus style)
2. **Starship** - Cross-shell prompt
3. **tmux** - Terminal multiplexer
4. **ranger** - Terminal file manager
5. **fzf** - Fuzzy finder
6. **exa** / **lsd** - Modern `ls` replacement
7. **bat** - Better `cat` with syntax highlighting
8. **ripgrep** - Fast search tool

### **Developer Tools**
1. **Docker & Docker Compose** - Containerization
2. **Postman** - API testing
3. **DBeaver** - Database management
4. **Redis** - In-memory database
5. **PostgreSQL** / **MySQL** - Relational databases
6. **MongoDB** - NoSQL database
7. **Maven & Gradle** - Java build tools (auto-installed with Java)

### **Gaming Enhancements**
1. **Lutris** - Game launcher for non-Steam games
2. **Heroic Games Launcher** - Epic Games & GOG launcher
3. **Wine-staging** - Windows compatibility layer
4. **Proton-GE** - Custom Proton builds
5. **MangoHud** - In-game FPS overlay
6. **CoreCtrl** - AMD GPU overclocking (alternative to NVIDIA tools)

### **GNOME Extensions** (Additional Suggestions)
1. **GSConnect** - KDE Connect integration
2. **Caffeine** - Disable auto-suspend
3. **Night Theme Switcher** - Auto dark/light theme
4. **Unite** - Unity-like UI
5. **Desktop Icons NG** - Desktop icon support
6. **OpenWeather** - Weather in top bar
7. **Sound Input & Output Device Chooser** - Quick audio switching
8. **Removable Drive Menu** - USB drive management

### **Accessibility Features**
1. **Orca** - Screen reader
2. **GNOME Accessibility features** - High contrast, large text, etc.
3. **onboard** - On-screen keyboard
4. **GNOME Magnifier** - Screen magnification

### **Network Tools**
1. **Wireshark** - Network protocol analyzer
2. **nmap** - Network scanner
3. **curl & wget** - Download tools
4. **OpenVPN** / **WireGuard** - VPN clients
5. **Remmina** - Remote desktop client

### **Custom Elysium Features**
1. **Welcome App** - Post-install wizard (like Manjaro Hello)
2. **System Update Notifier** - GNOME extension for updates
3. **Quick Setup Shortcuts** - Desktop shortcuts for common tasks
4. **ElysiumArch Toolkit** - Custom GUI for system management
5. **Auto-update Script** - Keep system packages current

---

## 🛠️ Customization Guide

### Modify Package Lists
Edit files in `packages/` before running the installer:
```bash
nano packages/application-packages.txt
# Add or remove applications as needed
```

### Change Theme Colors
Edit `configs/gnome/settings.ini`:
```ini
# Change accent color from blue to another color
accent-color='purple'  # Options: red, orange, yellow, green, blue, purple, pink
```

### Add Custom Wallpapers
Place your wallpapers in `assets/wallpapers/` before installation.

### Modify Partitioning Scheme
Edit `modules/03-disk.sh`:
```bash
# Current scheme: 512MB EFI, 4GB Swap, Rest for Root
# Modify partition sizes as needed
```

### Skip Optional Components
Comment out lines in `install.sh` to skip certain modules:
```bash
# source modules/10-applications.sh  # Skip application installation
```

---

## 📝 Post-Installation

### First Boot
1. System will boot directly into GNOME (GDM auto-login disabled for security)
2. Login with your created user account
3. Post-reboot script will run automatically (first login only)
4. Multi-monitor setup will be detected and configured
5. All applications available in app launcher

### Recommended First Steps
1. **Update System**: `yay -Syu`
2. **Create Timeshift Snapshot**: Open Timeshift and create first snapshot
3. **Configure IDEs**: Open VSCode and IntelliJ, install additional extensions
4. **Test NVIDIA Drivers**: Run `nvidia-smi` to verify GPU detection
5. **Configure Steam**: Enable Proton for all games in Steam settings
6. **Explore GNOME Extensions**: Open Extensions app and configure

### Java Version Management
Switch between Java versions:
```bash
# List installed Java versions
archlinux-java status

# Set default Java version
sudo archlinux-java set java-17-openjdk
# or
sudo archlinux-java set java-21-openjdk
```

### Multi-Monitor Setup
Adjust display settings:
```bash
# GNOME Settings > Displays
# Or use xrandr for manual configuration
xrandr --output HDMI-0 --right-of DP-0 --auto
```

---

## 🐛 Troubleshooting

See `docs/TROUBLESHOOTING.md` for detailed solutions.

### Common Issues

**Issue: No WiFi detected during installation**
- Solution: Install necessary WiFi drivers for your specific adapter before running installer

**Issue: NVIDIA drivers not loading**
- Solution: Check `logs/install.log` for errors. May need to rebuild initramfs: `sudo mkinitcpio -P`

**Issue: GRUB not booting**
- Solution: Boot from Arch ISO, chroot into system, reinstall GRUB: `grub-install --target=x86_64-efi`

**Issue: GNOME not starting**
- Solution: Check if GDM is enabled: `sudo systemctl status gdm` and start it: `sudo systemctl start gdm`

**Issue: Steam games not launching**
- Solution: Ensure Proton is enabled in Steam settings. Install `steam-native-runtime` if needed.

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:
1. Fork the repository
2. Create a feature branch
3. Test your changes in a VM
4. Submit a pull request with detailed description

### Areas for Contribution
- Additional application suggestions
- Theme improvements
- Bug fixes and optimizations
- Documentation enhancements
- Localization (translate to other languages)

---

## 📜 License

This project is licensed under the MIT License - see the `LICENSE` file for details.

---

## 🙏 Acknowledgments

- **Chris Titus Tech** - Inspiration for the installer approach
- **Arch Linux Community** - For the amazing distribution
- **GNOME Team** - For the beautiful desktop environment
- **AUR Maintainers** - For packaging thousands of applications

---

## 📞 Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/Trinitysudo/ElysiumArch/issues)
- **Arch Wiki**: [Comprehensive Linux documentation](https://wiki.archlinux.org/)
- **Reddit**: r/archlinux for community support

---

## 🚀 Quick Reference

### Installation Command
```bash
curl -L https://github.com/Trinitysudo/ElysiumArch/archive/main.tar.gz | tar xz && cd ElysiumArch-main && chmod +x install.sh && ./install.sh
```

### System Maintenance Commands
```bash
# Full system update (includes AUR)
yay -Syu

# Clean package cache
yay -Sc

# Remove orphaned packages
yay -Yc

# Create Timeshift snapshot
sudo timeshift --create --comments "Manual Snapshot"

# Check system info
fastfetch

# Monitor NVIDIA GPU
watch -n 1 nvidia-smi
```

---

<div align="center">

**Made with ❤️ for the Arch Linux community**

![Arch Linux](https://img.shields.io/badge/Built%20for-Arch%20Linux-1793D1?logo=arch-linux&logoColor=fff)

</div>
