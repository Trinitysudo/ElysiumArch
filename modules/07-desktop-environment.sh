#!/usr/bin/env bash
#
# Module 07: Desktop Environment Installation
# BARE MINIMUM - Just Hyprland + dependencies
#

print_info "Installing Hyprland (bare minimum)..."

# Install ONLY Hyprland and critical dependencies
arch-chroot /mnt pacman -S --noconfirm --needed \
    hyprland \
    kitty \
    xdg-desktop-portal-hyprland

if [[ $? -ne 0 ]]; then
    print_error "Failed to install Hyprland"
    exit 1
fi

print_success "Hyprland installed (bare minimum)"
print_info "After reboot: Login and run 'Hyprland' to start"
