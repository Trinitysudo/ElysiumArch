#!/usr/bin/env bash
#
# Module 03: Disk Management
# Select disk, partition scheme, format, and mount
#

print_info "Starting disk management..."

# List available disks
print_info "Available disks:"
echo ""
lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk
echo ""

# Get list of disks
DISKS=($(lsblk -d -o NAME -n | grep -E "^(sd|nvme|vd)"))

if [[ ${#DISKS[@]} -eq 0 ]]; then
    print_error "No disks found!"
    log_error "Disk: No disks detected"
    exit 1
fi

# If only one disk, auto-select it (with confirmation)
if [[ ${#DISKS[@]} -eq 1 ]]; then
    DISK="/dev/${DISKS[0]}"
    print_info "Only one disk detected: $DISK"
    lsblk "$DISK"
    if ! confirm "Use this disk for installation?"; then
        print_error "Installation cancelled"
        exit 1
    fi
else
    # Multiple disks, let user choose
    print_info "Select installation disk:"
    for i in "${!DISKS[@]}"; do
        echo "$((i+1))) /dev/${DISKS[$i]} ($(lsblk -d -o SIZE -n /dev/${DISKS[$i]}))"
    done
    
    while true; do
        read -p "Select disk [1-${#DISKS[@]}]: " disk_choice
        if [[ "$disk_choice" =~ ^[0-9]+$ ]] && [[ $disk_choice -ge 1 ]] && [[ $disk_choice -le ${#DISKS[@]} ]]; then
            DISK="/dev/${DISKS[$((disk_choice-1))]}"
            break
        else
            print_error "Invalid selection"
        fi
    done
fi

# Show selected disk info
print_info "Selected disk: $DISK"
echo ""
lsblk "$DISK"
echo ""

# Partition scheme selection
print_info "Select partition scheme:"
echo "1) Full disk (no swap) - Recommended for 16GB+ RAM"
echo "2) With swap partition (4GB swap)"
echo "3) Custom (advanced)"

read -p "Select option [1-3] (default: 1): " scheme_choice
scheme_choice=${scheme_choice:-1}

export PARTITION_SCHEME="$scheme_choice"

case $scheme_choice in
    1)
        print_info "Selected: Full disk (no swap)"
        USE_SWAP=false
        ;;
    2)
        print_info "Selected: With 4GB swap partition"
        USE_SWAP=true
        ;;
    3)
        print_info "Custom partitioning:"
        read -p "Create swap partition? [y/N]: " custom_swap
        if [[ "$custom_swap" =~ ^[yY]$ ]]; then
            read -p "Enter swap size in GB (e.g., 4): " swap_size
            swap_size=${swap_size:-4}
            USE_SWAP=true
            SWAP_SIZE="${swap_size}"
        else
            USE_SWAP=false
        fi
        ;;
    *)
        print_warning "Invalid choice, using default (no swap)"
        USE_SWAP=false
        ;;
esac

export USE_SWAP
export SWAP_SIZE=${SWAP_SIZE:-4}

# Final confirmation
print_warning "=========================================="
print_warning "  WARNING - DATA WILL BE ERASED!"
print_warning "=========================================="
print_warning "Disk: $DISK"
print_warning "Scheme: $([ "$USE_SWAP" = true ] && echo "EFI + Swap + Root" || echo "EFI + Root (no swap)")"
print_warning "ALL data will be permanently deleted!"
echo ""

if ! confirm "Proceed with installation?"; then
    print_error "Installation cancelled by user"
    log_error "Disk: User cancelled installation"
    exit 1
fi

# Export disk variable
export INSTALL_DISK="$DISK"
log_info "Disk: Selected disk $DISK for installation (swap: $USE_SWAP)"

# Determine partition naming scheme
if [[ "$DISK" =~ "nvme" ]] || [[ "$DISK" =~ "mmcblk" ]]; then
    PART_PREFIX="${DISK}p"
else
    PART_PREFIX="${DISK}"
fi
export PART_PREFIX

# Set partition variables based on scheme
EFI_PART="${PART_PREFIX}1"
if [ "$USE_SWAP" = true ]; then
    SWAP_PART="${PART_PREFIX}2"
    ROOT_PART="${PART_PREFIX}3"
    export EFI_PART SWAP_PART ROOT_PART
    
    print_info "Partition scheme:"
    print_info "  EFI:  $EFI_PART (512 MB)"
    print_info "  SWAP: $SWAP_PART (${SWAP_SIZE} GB)"
    print_info "  ROOT: $ROOT_PART (remaining space)"
else
    ROOT_PART="${PART_PREFIX}2"
    export EFI_PART ROOT_PART
    
    print_info "Partition scheme:"
    print_info "  EFI:  $EFI_PART (512 MB)"
    print_info "  ROOT: $ROOT_PART (remaining space)"
fi

# Unmount any mounted partitions
print_info "Unmounting any mounted partitions..."
umount -R /mnt 2>/dev/null || true
swapoff -a 2>/dev/null || true

# Wipe disk
print_info "Wiping disk..."
wipefs -af "$DISK"
sgdisk --zap-all "$DISK"

# Create partitions based on scheme
print_info "Creating partitions..."
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart primary fat32 1MiB 513MiB
parted -s "$DISK" set 1 esp on

if [ "$USE_SWAP" = true ]; then
    # With swap
    SWAP_END_MB=$((513 + SWAP_SIZE * 1024))
    parted -s "$DISK" mkpart primary linux-swap 513MiB ${SWAP_END_MB}MiB
    parted -s "$DISK" mkpart primary ext4 ${SWAP_END_MB}MiB 100%
else
    # No swap
    parted -s "$DISK" mkpart primary ext4 513MiB 100%
fi

# Wait for kernel to recognize partitions
sleep 2
partprobe "$DISK"
sleep 2

# Verify partitions exist
if [[ ! -b "$EFI_PART" ]] || [[ ! -b "$ROOT_PART" ]]; then
    print_error "Failed to create partitions!"
    log_error "Disk: Partition creation failed"
    exit 1
fi

if [ "$USE_SWAP" = true ] && [[ ! -b "$SWAP_PART" ]]; then
    print_error "Failed to create swap partition!"
    log_error "Disk: Swap partition creation failed"
    exit 1
fi

print_success "Partitions created successfully"
log_success "Disk: Partitions created on $DISK"

# Format partitions
print_info "Formatting partitions..."

print_info "Formatting EFI partition ($EFI_PART)..."
mkfs.fat -F32 "$EFI_PART"

if [ "$USE_SWAP" = true ]; then
    print_info "Creating swap ($SWAP_PART)..."
    mkswap "$SWAP_PART"
fi

print_info "Formatting root partition ($ROOT_PART)..."
mkfs.ext4 -F "$ROOT_PART"

print_success "Partitions formatted successfully"
log_success "Disk: Partitions formatted"

# Mount partitions
print_info "Mounting partitions..."

print_info "Mounting root partition..."
mount "$ROOT_PART" /mnt

print_info "Creating EFI mount point..."
mkdir -p /mnt/boot/efi
mount "$EFI_PART" /mnt/boot/efi

if [ "$USE_SWAP" = true ]; then
    print_info "Enabling swap..."
    swapon "$SWAP_PART"
else
    print_info "No swap partition (using zram if needed)"
fi

print_success "Partitions mounted successfully"
log_success "Disk: Partitions mounted"

# Verify mounts
print_info "Current mount status:"
lsblk "$DISK"

print_success "Disk management complete"
log_success "Disk management completed successfully"
