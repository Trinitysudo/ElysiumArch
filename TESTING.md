# ElysiumArch Testing Guide

## VM Detection Logic Verification

### Detection Method
The installer uses `systemd-detect-virt --quiet` to detect virtualization.

**Returns 0 (success/true):** Running in VM (VMware, VirtualBox, KVM, QEMU, etc.)  
**Returns 1 (failure/false):** Running on bare metal

### Test Scenarios

#### ✅ Scenario 1: Real Hardware with NVIDIA GPU (Production)
```bash
# What happens:
systemd-detect-virt --quiet          # Returns 1 (false) - NOT in VM
! systemd-detect-virt --quiet        # Evaluates to true
lspci | grep -i nvidia               # Finds "NVIDIA RTX 3060"

# Result:
- NVIDIA drivers: INSTALLED ✅
- lib32-nvidia-utils: INSTALLED ✅
- nvtop: INSTALLED ✅
- Summary shows: "✓ NVIDIA drivers installed"
```

#### ✅ Scenario 2: Virtual Machine (VMware/VirtualBox)
```bash
# What happens:
systemd-detect-virt --quiet          # Returns 0 (true) - VM detected
# Module exits early

# Result:
- NVIDIA drivers: SKIPPED ✅
- lib32-nvidia-utils: SKIPPED ✅
- nvtop: SKIPPED ✅
- Summary shows: "✓ Graphics drivers configured"
```

#### ✅ Scenario 3: Real Hardware WITHOUT NVIDIA (AMD/Intel GPU)
```bash
# What happens:
systemd-detect-virt --quiet          # Returns 1 (false) - NOT in VM
! systemd-detect-virt --quiet        # Evaluates to true
lspci | grep -i nvidia               # Finds nothing (AMD/Intel GPU)

# Result:
- NVIDIA drivers: SKIPPED ✅
- lib32-nvidia-utils: SKIPPED ✅
- nvtop: SKIPPED ✅
- Summary shows: "✓ Graphics drivers configured"
```

### Code Verification

#### Module 06 - NVIDIA Drivers
```bash
# VM Detection (Exit early if VM)
if systemd-detect-virt --quiet; then
    VIRT_TYPE=$(systemd-detect-virt)
    print_warning "Virtual machine detected: $VIRT_TYPE"
    print_info "Skipping NVIDIA driver installation (not needed in VM)"
    exit 0
fi

# GPU Detection (Exit if no NVIDIA)
if ! lspci | grep -i nvidia &>/dev/null; then
    print_warning "No NVIDIA GPU detected"
    print_info "Skipping NVIDIA driver installation"
    exit 0
fi

# Only reaches here if: NOT VM AND NVIDIA GPU present
print_info "Installing NVIDIA drivers..."
```

#### Module 10 - Applications (Steam)
```bash
STEAM_PACKAGES="steam vulkan-icd-loader lib32-vulkan-icd-loader"

# Add NVIDIA libs ONLY if: NOT VM AND NVIDIA GPU present
if ! systemd-detect-virt --quiet && lspci | grep -i nvidia &>/dev/null; then
    STEAM_PACKAGES="$STEAM_PACKAGES lib32-nvidia-utils"
fi

pacman -S $STEAM_PACKAGES
```

#### Module 11 - Utilities (nvtop)
```bash
# Install nvtop ONLY if: NOT VM AND NVIDIA GPU present
if ! systemd-detect-virt --quiet && lspci | grep -i nvidia &>/dev/null; then
    pacman -S nvtop
fi
```

### Summary Display Logic
```bash
# Shows appropriate message based on actual hardware
if ! systemd-detect-virt --quiet && lspci | grep -i nvidia &>/dev/null; then
    print_info "✓ NVIDIA drivers installed"
else
    print_info "✓ Graphics drivers configured"
fi
```

## Testing Commands

### Check if in VM (run in ArchISO)
```bash
systemd-detect-virt          # Shows VM type or "none"
systemd-detect-virt --quiet  # Silent (exit code only)
echo $?                      # 0=VM, 1=bare-metal
```

### Check for NVIDIA GPU
```bash
lspci | grep -i nvidia       # Shows NVIDIA devices
lspci | grep -i vga          # Shows all graphics cards
```

### Test the logic manually
```bash
# Test 1: VM detection
if systemd-detect-virt --quiet; then
    echo "In VM - would skip NVIDIA"
else
    echo "Bare metal - checking for NVIDIA..."
fi

# Test 2: Full logic
if ! systemd-detect-virt --quiet && lspci | grep -i nvidia &>/dev/null; then
    echo "Would install NVIDIA drivers"
else
    echo "Would skip NVIDIA drivers"
fi
```

## Expected Behavior Matrix

| Environment | systemd-detect-virt | NVIDIA GPU | Install NVIDIA? | Install lib32? | Install nvtop? |
|-------------|--------------------:|:----------:|:---------------:|:--------------:|:--------------:|
| Real HW + NVIDIA RTX 3060 | Returns 1 (false) | ✅ Present | ✅ YES | ✅ YES | ✅ YES |
| Real HW + AMD GPU | Returns 1 (false) | ❌ Absent | ❌ NO | ❌ NO | ❌ NO |
| Real HW + Intel GPU | Returns 1 (false) | ❌ Absent | ❌ NO | ❌ NO | ❌ NO |
| VMware VM | Returns 0 (true) | ❌ N/A | ❌ NO | ❌ NO | ❌ NO |
| VirtualBox VM | Returns 0 (true) | ❌ N/A | ❌ NO | ❌ NO | ❌ NO |
| KVM/QEMU VM | Returns 0 (true) | ❌ N/A | ❌ NO | ❌ NO | ❌ NO |
| Hyper-V VM | Returns 0 (true) | ❌ N/A | ❌ NO | ❌ NO | ❌ NO |

## Validation Checklist

✅ **VM Detection:** Uses `systemd-detect-virt --quiet` (reliable, standard tool)  
✅ **GPU Detection:** Uses `lspci | grep -i nvidia` (hardware check)  
✅ **Conditional Logic:** `! systemd-detect-virt --quiet && lspci | grep -i nvidia`  
✅ **Early Exit:** Module 06 exits early if VM or no GPU  
✅ **Consistent Logic:** Same check used in modules 06, 10, 11, and install.sh  
✅ **Graceful Degradation:** No errors if NVIDIA skipped, just different packages  
✅ **User Feedback:** Clear messages about what's being skipped and why  

## Conclusion

**The installer will work perfectly in BOTH scenarios:**

1. **On your real RTX 3060 system:** Full NVIDIA support installed ✅
2. **In a VM for testing:** NVIDIA components skipped, no errors ✅

The logic is **sound and properly inverted** using the `!` operator.
