#!/usr/bin/env bash
#
# Module 06: NVIDIA Drivers Installation
# Install and configure NVIDIA proprietary drivers for RTX 3060
#

# Detect if running in VM
if systemd-detect-virt --quiet; then
    VIRT_TYPE=$(systemd-detect-virt)
    print_warning "Virtual machine detected: $VIRT_TYPE"
    print_info "Skipping NVIDIA driver installation (not needed in VM)"
    log_info "NVIDIA: Skipped - running in $VIRT_TYPE"
    exit 0
fi

# Check if NVIDIA GPU is present
if ! lspci | grep -i nvidia &>/dev/null; then
    print_warning "No NVIDIA GPU detected"
    print_info "Skipping NVIDIA driver installation"
    log_info "NVIDIA: Skipped - no NVIDIA GPU found"
    exit 0
fi

print_info "Installing NVIDIA drivers for RTX 3060..."

# Enable multilib repository for 32-bit support
print_info "Enabling multilib repository for 32-bit NVIDIA libraries..."
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

# Install NVIDIA drivers and utilities
print_info "Installing NVIDIA packages..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    nvidia \
    nvidia-utils \
    nvidia-settings \
    lib32-nvidia-utils \
    opencl-nvidia

if [[ $? -ne 0 ]]; then
    print_error "Failed to install NVIDIA drivers"
    log_error "NVIDIA: Driver installation failed"
    exit 1
fi

print_success "NVIDIA drivers installed"
log_success "NVIDIA: Drivers installed"

# Install CUDA (optional, for development)
print_info "Installing CUDA toolkit (optional)..."
arch-chroot /mnt pacman -S --noconfirm --needed cuda cudnn 2>/dev/null || print_warning "CUDA/cuDNN install skipped (optional)"

# Configure early KMS (Kernel Mode Setting)
print_info "Configuring kernel modules..."

# Add NVIDIA modules to mkinitcpio
sed -i 's/^MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /mnt/etc/mkinitcpio.conf

# Regenerate initramfs
arch-chroot /mnt mkinitcpio -P

print_success "Kernel modules configured"
log_success "NVIDIA: Kernel modules added to initramfs"

# Configure NVIDIA kernel parameters
print_info "Configuring NVIDIA kernel parameters..."

# Add NVIDIA DRM to GRUB cmdline
if grep -q "GRUB_CMDLINE_LINUX_DEFAULT" /mnt/etc/default/grub; then
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia-drm.modeset=1"/' /mnt/etc/default/grub
fi

print_success "Kernel parameters configured"

# Create NVIDIA Xorg configuration
print_info "Creating Xorg configuration for NVIDIA..."

mkdir -p /mnt/etc/X11/xorg.conf.d/
cat > /mnt/etc/X11/xorg.conf.d/10-nvidia.conf << 'EOF'
Section "OutputClass"
    Identifier "nvidia"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "AllowEmptyInitialConfiguration"
    Option "PrimaryGPU" "yes"
    ModulePath "/usr/lib/nvidia/xorg"
    ModulePath "/usr/lib/xorg/modules"
EndSection
EOF

print_success "Xorg configuration created"
log_success "NVIDIA: Xorg configuration created"

# Configure NVIDIA settings for Wayland
print_info "Configuring NVIDIA for Wayland compatibility..."

cat > /mnt/etc/modprobe.d/nvidia.conf << EOF
options nvidia_drm modeset=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF

print_success "Wayland compatibility configured"

# Enable NVIDIA persistence service
arch-chroot /mnt systemctl enable nvidia-persistenced

print_success "NVIDIA services enabled"

# Create NVIDIA-specific GNOME settings
print_info "Configuring GNOME for NVIDIA..."

mkdir -p /mnt/usr/share/gdm/greeter/autostart/
cat > /mnt/usr/share/gdm/greeter/autostart/optimus.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Optimus
Exec=sh -c "xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto"
NoDisplay=true
X-GNOME-Autostart-Phase=DisplayServer
EOF

print_success "GNOME NVIDIA configuration complete"

# Verify installation
print_info "Verifying NVIDIA driver installation..."
if arch-chroot /mnt pacman -Q nvidia &>/dev/null; then
    NVIDIA_VERSION=$(arch-chroot /mnt pacman -Q nvidia | awk '{print $2}')
    print_success "NVIDIA driver version: $NVIDIA_VERSION"
    log_success "NVIDIA: Driver version $NVIDIA_VERSION installed"
else
    print_warning "Could not verify NVIDIA driver version"
fi

print_success "NVIDIA driver installation complete"
print_info "Note: nvidia-smi will be available after reboot"
log_success "NVIDIA driver installation completed successfully"
