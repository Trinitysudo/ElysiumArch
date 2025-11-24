#!/usr/bin/env bash
#
# Module 04: Base System Installation
# Install base Arch Linux system and configure
#

print_info "Installing base Arch Linux system..."

# Update package database
print_info "Updating package database..."
pacman -Sy

# Install base system
print_info "Installing base packages (this may take 10-15 minutes)..."
print_info "Packages: base, base-devel, linux, linux-firmware, linux-headers..."

pacstrap /mnt base base-devel linux linux-firmware linux-headers

if [[ $? -ne 0 ]]; then
    print_error "Failed to install base system"
    log_error "Base: pacstrap failed"
    exit 1
fi

print_success "Base system installed"
log_success "Base: Base system installed via pacstrap"

# Install essential packages
print_info "Installing essential packages..."
pacstrap /mnt \
    grub efibootmgr os-prober \
    amd-ucode \
    networkmanager dhcpcd iwd \
    sudo nano vim \
    git wget curl \
    man-db man-pages \
    ntfs-3g \
    ufw

print_success "Essential packages installed"
log_success "Base: Essential packages installed"

# Generate fstab
print_info "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

if [[ -f /mnt/etc/fstab ]]; then
    print_success "fstab generated"
    log_success "Base: fstab generated"
else
    print_error "Failed to generate fstab"
    log_error "Base: fstab generation failed"
    exit 1
fi

# Configure system in chroot
print_info "Configuring system..."

# Set timezone
arch-chroot /mnt ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
arch-chroot /mnt hwclock --systohc
print_success "Timezone configured"

# Configure locale
echo "$LOCALE UTF-8" > /mnt/etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen  # Always include English as fallback
arch-chroot /mnt locale-gen
echo "LANG=$LOCALE" > /mnt/etc/locale.conf
print_success "Locale configured"

# Set keyboard layout
if [[ -n "$KEYMAP" ]]; then
    echo "KEYMAP=$KEYMAP" > /mnt/etc/vconsole.conf
    print_success "Keyboard layout configured: $KEYMAP"
else
    print_warning "KEYMAP not set, skipping vconsole.conf"
fi

# Set hostname
echo "$HOSTNAME" > /mnt/etc/hostname
cat > /mnt/etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF
print_success "Hostname configured: $HOSTNAME"

# Set root password
print_info "Setting root password..."
echo "root:$ROOT_PASSWORD" | arch-chroot /mnt chpasswd
print_success "Root password set"
log_info "Base: Root password configured"

# Create user account
print_info "Creating user account: $USERNAME..."
arch-chroot /mnt useradd -m -G wheel,audio,video,storage,optical,input,seat -s /bin/bash "$USERNAME"
echo "$USERNAME:$USER_PASSWORD" | arch-chroot /mnt chpasswd
print_success "User account created: $USERNAME (with Wayland permissions)"
log_info "Base: User account created: $USERNAME"

# Configure sudo
print_info "Configuring sudo access..."
# Comment out password-required line and enable NOPASSWD for installation
sed -i 's/^%wheel ALL=(ALL:ALL) ALL/# %wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /mnt/etc/sudoers
print_success "Sudo access configured for wheel group (NOPASSWD enabled for installation)"

# Enable NetworkManager
arch-chroot /mnt systemctl enable NetworkManager
print_success "NetworkManager enabled"

# Enable DHC PCD for fallback
arch-chroot /mnt systemctl enable dhcpcd
print_success "DHCPCD enabled"

# Enable and configure firewall
print_info "Configuring firewall (UFW)..."
arch-chroot /mnt systemctl enable ufw
arch-chroot /mnt ufw default deny incoming
arch-chroot /mnt ufw default allow outgoing
arch-chroot /mnt ufw --force enable
print_success "Firewall enabled and configured"

print_success "Base system configuration complete"
log_success "Base system installation and configuration completed"
