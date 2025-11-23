#!/usr/bin/env bash
#
# Module 05: Bootloader Installation
# Install and configure GRUB bootloader
#

print_info "Installing GRUB bootloader..."

# Verify EFI partition is mounted
if ! mountpoint -q /mnt/boot/efi; then
    print_error "EFI partition not mounted at /mnt/boot/efi"
    print_info "Current mounts:"
    mount | grep /mnt
    log_error "Bootloader: EFI partition not mounted"
    exit 1
fi

# Install efibootmgr if not already installed
arch-chroot /mnt pacman -S --noconfirm --needed efibootmgr

# Install GRUB for UEFI (with fallback for BIOS)
print_info "Installing GRUB to EFI partition..."
if [[ -d /sys/firmware/efi ]]; then
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ElysiumArch --recheck
else
    print_warning "UEFI not detected, installing for BIOS..."
    arch-chroot /mnt grub-install --target=i386-pc "$INSTALL_DISK"
fi

if [[ $? -ne 0 ]]; then
    print_error "Failed to install GRUB"
    log_error "Bootloader: GRUB installation failed"
    exit 1
fi

print_success "GRUB installed to EFI"
log_success "Bootloader: GRUB installed"

# Enable os-prober for dual-boot detection
print_info "Enabling os-prober for dual-boot detection..."
echo "GRUB_DISABLE_OS_PROBER=false" >> /mnt/etc/default/grub

# Configure GRUB timeout
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=3/' /mnt/etc/default/grub

# Add NVIDIA kernel parameters if NVIDIA drivers are installed
if grep -q "nvidia" /mnt/etc/mkinitcpio.conf 2>/dev/null; then
    print_info "Adding NVIDIA kernel parameters to GRUB..."
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia-drm.modeset=1"/' /mnt/etc/default/grub
fi

# Generate GRUB configuration
print_info "Generating GRUB configuration..."
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

if [[ $? -ne 0 ]]; then
    print_error "Failed to generate GRUB config"
    log_error "Bootloader: GRUB config generation failed"
    exit 1
fi

print_success "GRUB configuration generated"
log_success "Bootloader: GRUB configured"

# Verify bootloader installation
if [[ -f /mnt/boot/grub/grub.cfg ]]; then
    print_success "Bootloader installation verified"
    log_success "Bootloader: Installation complete"
else
    print_warning "Could not verify GRUB configuration file"
    log_warning "Bootloader: Verification failed"
fi

print_success "Bootloader installation complete"
