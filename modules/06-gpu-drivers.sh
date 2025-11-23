#!/usr/bin/env bash
#
# Module 06: GPU Drivers Installation
# Detect and install appropriate GPU drivers (NVIDIA, AMD, or Intel)
#

print_info "Detecting GPU hardware..."

# Detect if running in VM
if systemd-detect-virt --quiet; then
    VIRT_TYPE=$(systemd-detect-virt)
    print_warning "Virtual machine detected: $VIRT_TYPE"
    print_info "Using generic VM graphics drivers"
    log_info "GPU: Skipped hardware drivers - running in $VIRT_TYPE"
    
    # Install basic mesa for VMs
    arch-chroot /mnt pacman -S --noconfirm --needed mesa xf86-video-vesa
    print_success "VM graphics drivers installed"
    
    mkdir -p /mnt/var/log/elysium
    echo "VM" > /mnt/var/log/elysium/gpu_type
    exit 0
fi

# Detect GPU type
GPU_NVIDIA=$(lspci | grep -i nvidia | grep -i vga)
GPU_AMD=$(lspci | grep -i amd | grep -i vga)
GPU_INTEL=$(lspci | grep -i intel | grep -i vga)

# Display detected GPUs
print_info "GPU Detection Results:"
if [[ -n "$GPU_NVIDIA" ]]; then
    print_info "  ✓ NVIDIA GPU detected: $(echo "$GPU_NVIDIA" | cut -d: -f3 | xargs)"
    echo "NVIDIA" > /mnt/var/log/elysium/gpu_type
fi
if [[ -n "$GPU_AMD" ]]; then
    print_info "  ✓ AMD GPU detected: $(echo "$GPU_AMD" | cut -d: -f3 | xargs)"
    echo "AMD" > /mnt/var/log/elysium/gpu_type
fi
if [[ -n "$GPU_INTEL" ]]; then
    print_info "  ✓ Intel GPU detected: $(echo "$GPU_INTEL" | cut -d: -f3 | xargs)"
    [[ -z "$(cat /mnt/var/log/elysium/gpu_type 2>/dev/null)" ]] && echo "INTEL" > /mnt/var/log/elysium/gpu_type
fi

# Install drivers based on detected GPU
if [[ -n "$GPU_NVIDIA" ]]; then
    print_info "Installing NVIDIA drivers..."
    
    # Enable multilib repository for 32-bit support
    print_info "Enabling multilib repository for 32-bit libraries..."
    if ! grep -q "^\[multilib\]" /mnt/etc/pacman.conf; then
        cat >> /mnt/etc/pacman.conf << 'EOF'

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
        print_success "Multilib repository enabled"
        arch-chroot /mnt pacman -Sy
    fi
    
    # Install NVIDIA drivers
    arch-chroot /mnt pacman -S --noconfirm --needed \
        nvidia \
        nvidia-utils \
        nvidia-settings \
        lib32-nvidia-utils \
        opencl-nvidia
    
    if [[ $? -eq 0 ]]; then
        print_success "NVIDIA drivers installed"
        log_success "GPU: NVIDIA drivers installed"
        
        # Configure NVIDIA modules in mkinitcpio
        if grep -q "^MODULES=()" /mnt/etc/mkinitcpio.conf; then
            sed -i 's/^MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /mnt/etc/mkinitcpio.conf
        else
            # If MODULES already has content, append NVIDIA modules
            sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /mnt/etc/mkinitcpio.conf
        fi
        arch-chroot /mnt mkinitcpio -P
        
        # Add kernel parameters
        if grep -q "GRUB_CMDLINE_LINUX_DEFAULT" /mnt/etc/default/grub; then
            sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia-drm.modeset=1"/' /mnt/etc/default/grub
        fi
        
        # Create Xorg config
        mkdir -p /mnt/etc/X11/xorg.conf.d/
        cat > /mnt/etc/X11/xorg.conf.d/10-nvidia.conf << 'NVIDIAEOF'
Section "OutputClass"
    Identifier "nvidia"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "AllowEmptyInitialConfiguration"
    Option "PrimaryGPU" "yes"
    ModulePath "/usr/lib/nvidia/xorg"
    ModulePath "/usr/lib/xorg/modules"
EndSection
NVIDIAEOF
        
        # Wayland compatibility
        cat > /mnt/etc/modprobe.d/nvidia.conf << 'NVIDIAMODEOF'
options nvidia_drm modeset=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
NVIDIAMODEOF
        
        arch-chroot /mnt systemctl enable nvidia-persistenced
        print_success "NVIDIA configuration complete"
        
        echo "NVIDIA_SUCCESS" >> /mnt/var/log/elysium/install_status
    else
        print_error "NVIDIA driver installation failed"
        log_error "GPU: NVIDIA driver installation failed"
        echo "NVIDIA_FAILED" >> /mnt/var/log/elysium/install_status
    fi
    
elif [[ -n "$GPU_AMD" ]]; then
    print_info "Installing AMD drivers..."
    
    # AMD drivers are in the standard repos and work well
    arch-chroot /mnt pacman -S --noconfirm --needed \
        mesa \
        xf86-video-amdgpu \
        vulkan-radeon \
        lib32-vulkan-radeon \
        libva-mesa-driver \
        lib32-libva-mesa-driver \
        mesa-vdpau \
        lib32-mesa-vdpau \
        opencl-mesa
    
    if [[ $? -eq 0 ]]; then
        print_success "AMD drivers installed"
        log_success "GPU: AMD drivers installed"
        
        # Enable early KMS for AMD
        if grep -q "^MODULES=()" /mnt/etc/mkinitcpio.conf; then
            sed -i 's/^MODULES=()/MODULES=(amdgpu radeon)/' /mnt/etc/mkinitcpio.conf
        else
            sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 amdgpu radeon)/' /mnt/etc/mkinitcpio.conf
        fi
        arch-chroot /mnt mkinitcpio -P
        
        # Add kernel parameters for AMD
        if grep -q "GRUB_CMDLINE_LINUX_DEFAULT" /mnt/etc/default/grub; then
            sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 amdgpu.dc=1"/' /mnt/etc/default/grub
        fi
        
        print_success "AMD configuration complete"
        echo "AMD_SUCCESS" >> /mnt/var/log/elysium/install_status
    else
        print_error "AMD driver installation failed"
        log_error "GPU: AMD driver installation failed"
        echo "AMD_FAILED" >> /mnt/var/log/elysium/install_status
    fi
    
elif [[ -n "$GPU_INTEL" ]]; then
    print_info "Installing Intel drivers..."
    
    # Intel drivers
    arch-chroot /mnt pacman -S --noconfirm --needed \
        mesa \
        xf86-video-intel \
        vulkan-intel \
        lib32-vulkan-intel \
        intel-media-driver \
        libva-intel-driver \
        lib32-libva-intel-driver
    
    if [[ $? -eq 0 ]]; then
        print_success "Intel drivers installed"
        log_success "GPU: Intel drivers installed"
        
        # Enable early KMS for Intel
        if grep -q "^MODULES=()" /mnt/etc/mkinitcpio.conf; then
            sed -i 's/^MODULES=()/MODULES=(i915)/' /mnt/etc/mkinitcpio.conf
        else
            sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 i915)/' /mnt/etc/mkinitcpio.conf
        fi
        arch-chroot /mnt mkinitcpio -P
        
        print_success "Intel configuration complete"
        echo "INTEL_SUCCESS" >> /mnt/var/log/elysium/install_status
    else
        print_error "Intel driver installation failed"
        log_error "GPU: Intel driver installation failed"
        echo "INTEL_FAILED" >> /mnt/var/log/elysium/install_status
    fi
    
else
    print_warning "No discrete GPU detected, using generic drivers"
    arch-chroot /mnt pacman -S --noconfirm --needed mesa
    print_success "Generic drivers installed"
    echo "GENERIC" > /mnt/var/log/elysium/gpu_type
    echo "GENERIC_SUCCESS" >> /mnt/var/log/elysium/install_status
fi

print_success "GPU driver installation complete"
log_success "GPU driver installation completed"
