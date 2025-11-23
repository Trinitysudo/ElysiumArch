#!/usr/bin/env bash
#
# Module 14: Post-Installation Configuration
# Final system optimization and configuration
#

print_info "Running post-installation configuration..."

# Enable multilib repository (32-bit support)
print_info "Enabling multilib repository..."

if ! grep -q "^\[multilib\]" /mnt/etc/pacman.conf; then
    cat >> /mnt/etc/pacman.conf << 'EOF'

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
    print_success "Multilib repository enabled"
    
    # Update package database
    arch-chroot /mnt pacman -Sy
else
    print_info "Multilib already enabled"
fi

# Optimize pacman configuration
print_info "Optimizing pacman configuration..."

sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /mnt/etc/pacman.conf
sed -i 's/#Color/Color/' /mnt/etc/pacman.conf

# Add ILoveCandy for fun progress bar
sed -i '/^Color/a ILoveCandy' /mnt/etc/pacman.conf

# Enable VerbosePkgLists
sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /mnt/etc/pacman.conf

print_success "Pacman optimized"

# Configure multi-monitor support
print_info "Preparing multi-monitor support..."

cat > /mnt/home/$USERNAME/.config/monitors.xml << 'EOF'
<monitors version="2">
  <configuration>
    <logicalmonitor>
      <x>0</x>
      <y>0</y>
      <scale>1</scale>
      <primary>yes</primary>
      <monitor>
        <monitorspec>
          <connector>HDMI-0</connector>
        </monitorspec>
        <mode>
          <width>1920</width>
          <height>1080</height>
          <rate>60</rate>
        </mode>
      </monitor>
    </logicalmonitor>
  </configuration>
</monitors>
EOF

chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME/.config

print_success "Multi-monitor configuration prepared"

# Set default applications
print_info "Configuring default applications..."

mkdir -p /mnt/home/$USERNAME/.config
cat > /mnt/home/$USERNAME/.config/mimeapps.list << 'EOF'
[Default Applications]
text/html=brave-browser.desktop
x-scheme-handler/http=brave-browser.desktop
x-scheme-handler/https=brave-browser.desktop
x-scheme-handler/about=brave-browser.desktop
x-scheme-handler/unknown=brave-browser.desktop
EOF

chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME/.config

print_success "Default applications configured"

# Clean package cache
print_info "Cleaning package cache..."
arch-chroot /mnt pacman -Sc --noconfirm

print_success "Package cache cleaned"

# Create welcome message
cat > /mnt/home/$USERNAME/WELCOME.txt << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║          Welcome to ElysiumArch!                              ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

Your Arch Linux system has been successfully installed!

🚀 Quick Start Commands:
  • Update system: yay -Syu
  • System info: fastfetch
  • GPU info: nvidia-smi
  • Create backup: sudo timeshift --create

📦 Installed Software:
  • Java: OpenJDK 17 (default) & 21
  • IDEs: Visual Studio Code, IntelliJ IDEA
  • Browser: Brave
  • Development: Node.js, Git, Python
  • Gaming: Steam, Modrinth Launcher
  • Media: VLC, OBS Studio
  • And much more!

🛡️ Security:
  • Enable firewall: sudo ufw enable
  • Check security: cat ~/SECURITY-INFO.txt

🎨 Theming:
  • Dark mode with blue accents enabled
  • Extensions: Open Extension Manager
  • Run: ~/install-extensions.sh

📚 Documentation:
  • GitHub: https://github.com/Trinitysudo/ElysiumArch
  • Issues: Report bugs on GitHub

Enjoy your new system! 🎉
EOF

chown $USERNAME:$USERNAME /mnt/home/$USERNAME/WELCOME.txt

print_success "Welcome message created"

# Generate system report
print_info "Generating installation report..."

cat > /mnt/home/$USERNAME/INSTALL-REPORT.txt << EOF
ElysiumArch Installation Report
================================
Installation Date: $(date)
Hostname: $HOSTNAME
Username: $USERNAME

System Information:
-------------------
Disk: $INSTALL_DISK
Partition Scheme: $([ "$USE_SWAP" = true ] && echo "EFI + Swap + Root" || echo "EFI + Root (no swap)")
Locale: $LOCALE
Timezone: $TIMEZONE
Keyboard: $KEYMAP

Installed Components:
---------------------
✓ Base Arch Linux system
✓ GRUB bootloader (UEFI)
✓ NVIDIA drivers (RTX 3060 optimized)
✓ GNOME desktop environment
✓ Package managers: pacman, yay, paru
✓ Java JDK 17 & 21
✓ Node.js & npm
✓ Visual Studio Code
✓ IntelliJ IDEA Community
✓ Brave Browser
✓ Discord
✓ Steam
✓ And many more applications...

Security Features:
------------------
✓ UFW Firewall
✓ Fail2Ban
✓ AppArmor
✓ System auditing

Post-Installation Tasks:
------------------------
1. Enable firewall: sudo ufw enable
2. Update system: yay -Syu
3. Create Timeshift snapshot
4. Run ~/install-extensions.sh
5. Configure IDEs and applications

Installation log: /var/log/elysium-install.log
EOF

chown $USERNAME:$USERNAME /mnt/home/$USERNAME/INSTALL-REPORT.txt

print_success "Installation report generated"

# Copy installation log
cp "$LOG_FILE" /mnt/var/log/elysium-install.log

print_success "Post-installation configuration complete"
log_success "Post-Install: All configurations applied"
