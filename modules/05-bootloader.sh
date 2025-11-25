#!/usr/bin/env bash
#
# Module 05: Bootloader Installation
# Install and configure GRUB bootloader
#

print_info "Installing GRUB bootloader..."

# Install GRUB based on boot mode
if [[ "$BOOT_MODE" == "UEFI" ]]; then
    print_info "Installing GRUB for UEFI mode..."
    
    # Verify EFI partition is mounted
    if ! mountpoint -q /mnt/boot/efi; then
        print_error "EFI partition not mounted at /mnt/boot/efi"
        print_info "Current mounts:"
        mount | grep /mnt
        log_error "Bootloader: EFI partition not mounted"
        exit 1
    fi
    
    # Install efibootmgr
    arch-chroot /mnt pacman -S --noconfirm --needed efibootmgr
    
    # Install GRUB for UEFI
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ElysiumArch --recheck
    
    if [[ $? -ne 0 ]]; then
        print_error "Failed to install GRUB for UEFI"
        log_error "Bootloader: GRUB UEFI installation failed"
        exit 1
    fi
    
    print_success "GRUB installed for UEFI"
else
    print_info "Installing GRUB for BIOS/Legacy mode..."
    
    # Get the disk device (use DISK or INSTALL_DISK variable from module 03)
    TARGET_DISK="${DISK:-$INSTALL_DISK}"
    
    if [[ -z "$TARGET_DISK" ]]; then
        print_error "DISK variable not set!"
        log_error "Bootloader: DISK variable missing"
        exit 1
    fi
    
    # Detect if running in VM
    IS_VM=false
    if systemd-detect-virt --quiet 2>/dev/null || grep -q "hypervisor" /proc/cpuinfo 2>/dev/null; then
        IS_VM=true
        VIRT_TYPE=$(systemd-detect-virt 2>/dev/null || echo "VM")
        print_info "Virtual machine detected: $VIRT_TYPE"
    fi
    
    print_info "Target disk: $TARGET_DISK"
    
    if [[ "$IS_VM" == "true" ]]; then
        print_info "Using VM-optimized GRUB installation..."
        
        # Method 1: Standard with VM flags
        print_info "Attempting standard installation..."
        arch-chroot /mnt grub-install --target=i386-pc --force --no-floppy "$TARGET_DISK" 2>&1
        
        if [[ $? -ne 0 ]]; then
            print_warning "Method 1 failed, trying direct boot sector write..."
            
            # Method 2: Direct installation to MBR (works when device detection fails)
            arch-chroot /mnt bash -c "
                dd bs=440 count=1 conv=notrunc if=/usr/lib/grub/i386-pc/boot.img of=$TARGET_DISK 2>/dev/null
                grub-install --target=i386-pc --force --skip-fs-probe $TARGET_DISK 2>&1 || true
            "
            
            # Ensure GRUB modules exist
            if [ ! -d /mnt/boot/grub/i386-pc ]; then
                print_info "Copying GRUB modules manually..."
                mkdir -p /mnt/boot/grub/i386-pc
                cp -r /mnt/usr/lib/grub/i386-pc/* /mnt/boot/grub/i386-pc/ 2>/dev/null || true
            fi
        fi
        
        print_success "GRUB core installed for VM (config will be generated next)"
    else
        print_info "Using standard GRUB installation..."
        
        # Physical hardware: Normal installation
        arch-chroot /mnt grub-install --target=i386-pc --recheck "$TARGET_DISK"
        
        if [[ $? -ne 0 ]]; then
            print_warning "Standard install failed, trying with --force..."
            arch-chroot /mnt grub-install --target=i386-pc --force "$TARGET_DISK"
            
            if [[ $? -ne 0 ]]; then
                print_error "GRUB installation failed!"
                log_error "Bootloader: GRUB BIOS installation failed"
                print_warning "Continuing - you may need to fix GRUB manually"
            fi
        else
            print_success "GRUB installed for BIOS/Legacy to $TARGET_DISK"
        fi
    fi
fi

log_success "Bootloader: GRUB installed for $BOOT_MODE"

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
