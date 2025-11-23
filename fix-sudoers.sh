#!/bin/bash
# Quick fix for sudoers configuration
# Run this from the ArchISO BEFORE resuming installation

echo "Fixing sudoers configuration..."

# Comment out password-required line
sed -i 's/^%wheel ALL=(ALL:ALL) ALL/# %wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers

# Enable NOPASSWD line
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /mnt/etc/sudoers

echo "Sudoers fixed! NOPASSWD is now active."
echo "You can now resume the installation with ./install.sh"
