# ElysiumArch - Simplified Installation Guide

## 🚀 Quick Start (Streamlined Process)

### Prerequisites
1. **Boot into Arch Linux ISO**
2. **Connect to internet FIRST** (the installer won't configure it for you)
   ```bash
   # For WiFi:
   iwctl
   station wlan0 scan
   station wlan0 connect YOUR_SSID
   exit
   
   # Test connection:
   ping archlinux.org
   ```

3. **Download and run ElysiumArch**
   ```bash
   curl -L https://github.com/Trinitysudo/ElysiumArch/archive/main.tar.gz | tar xz
   cd ElysiumArch-main
   chmod +x install.sh
   ./install.sh
   ```

---

## ⚡ Simplified Installation Process

### What's Changed (Streamlined)

#### ✅ **Network Configuration - SIMPLIFIED**
- ❌ **Removed**: Interactive WiFi setup wizard
- ✅ **Now**: Just verifies you're already connected
- **Why**: If you can download the installer, you already have internet!

#### ✅ **Disk Partitioning - MORE OPTIONS**
Now you can choose:

**Option 1: Full Disk (No Swap)** ⭐ *Recommended for 16GB+ RAM*
```
├── EFI (512MB)
└── Root (rest of disk)
```

**Option 2: With Swap Partition**
```
├── EFI (512MB)
├── Swap (4GB)
└── Root (rest of disk)
```

**Option 3: Custom**
```
Choose your own swap size or skip it entirely
```

- ❌ **Removed**: Mandatory 4GB swap
- ✅ **Now**: Optional swap (you choose!)
- **Why**: With 16GB RAM, swap is often unnecessary

#### ✅ **Security - ADDED**
New security features (Manjaro/Debian/EndeavourOS style):
- **UFW Firewall** - Easy firewall management
- **Fail2Ban** - Intrusion prevention
- **AppArmor** - Mandatory access control
- **System Auditing** - Track system events
- **Kernel Hardening** - Security parameters
- **Sudo Logging** - Track sudo usage

---

## 📋 Complete Installation Flow

```
[Boot Arch ISO]
        ↓
[Connect to Internet] ← YOU DO THIS FIRST!
        ↓
[Download ElysiumArch]
        ↓
[Run ./install.sh]
        ↓
┌─────────────────────────────────────┐
│ 1. System Check                     │
│    • Root user? ✓                   │
│    • UEFI mode? ✓                   │
│    • Internet? ✓ (auto-verified)    │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│ 2. Localization                     │
│    • Language selection             │
│    • Timezone (auto-detect)         │
│    • Keyboard layout                │
│    • Hostname                       │
│    • Username & passwords           │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│ 3. Disk Selection & Partitioning    │
│    • Select disk from list          │
│    • Choose partition scheme:       │
│      [1] No swap (recommended)      │
│      [2] With 4GB swap              │
│      [3] Custom swap size           │
│    • Confirm once                   │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│ 4-14. Automatic Installation        │
│    • Base system                    │
│    • GRUB bootloader                │
│    • NVIDIA drivers (RTX 3060)      │
│    • GNOME desktop                  │
│    • Package managers (yay, paru)   │
│    • Java JDK 17 & 21               │
│    • Development tools              │
│    • Applications (Brave, Discord)  │
│    • Utilities (Kitty, Kate)        │
│    • Theming (Dark + Blue)          │
│    • GNOME extensions               │
│    • Security configuration ✨ NEW  │
│    • Post-install optimization      │
└─────────────────────────────────────┘
        ↓
[Reboot into your new system!]
```

---

## 🛡️ Security Features (NEW!)

After installation, your system has:

### **Active Security**
- ✅ **UFW Firewall** (configured, enable with `sudo ufw enable`)
- ✅ **Fail2Ban** (running, protects against brute force)
- ✅ **AppArmor** (running, mandatory access control)
- ✅ **System Auditing** (running, logs security events)

### **Hardening Applied**
- ✅ IP spoofing protection
- ✅ ICMP redirect protection
- ✅ SYN flood protection
- ✅ Kernel security parameters
- ✅ Sudo command logging
- ✅ Secure file permissions (umask)

### **Security Commands**
```bash
# Enable firewall
sudo ufw enable
sudo ufw status

# Check Fail2Ban status
sudo systemctl status fail2ban
sudo fail2ban-client status

# Check AppArmor
sudo aa-status

# View audit logs
sudo ausearch -m avc -ts recent

# View sudo logs
sudo cat /var/log/sudo.log
```

### **Security Info File**
Check `~/SECURITY-INFO.txt` for complete security documentation!

---

## 💾 Disk Partition Schemes

### **Option 1: No Swap (Recommended for 16GB+ RAM)**
```
/dev/nvme0n1p1    512M    EFI System         /boot/efi
/dev/nvme0n1p2    REST    Linux filesystem   /
```

**Advantages:**
- ✅ More disk space for root
- ✅ No swap overhead
- ✅ Faster (no disk swapping)
- ✅ Perfect for 16GB+ RAM

**Use when:** You have 16GB+ RAM and SSD

---

### **Option 2: With Swap (Traditional)**
```
/dev/nvme0n1p1    512M    EFI System         /boot/efi
/dev/nvme0n1p2    4G      Linux swap         [SWAP]
/dev/nvme0n1p3    REST    Linux filesystem   /
```

**Advantages:**
- ✅ Hibernation support
- ✅ Better for low RAM systems
- ✅ Handles memory pressure

**Use when:** 
- You want hibernation
- You have less than 16GB RAM
- You run memory-intensive workloads

---

### **Option 3: Custom Swap**
```
/dev/nvme0n1p1    512M       EFI System         /boot/efi
/dev/nvme0n1p2    YOUR_SIZE  Linux swap         [SWAP]
/dev/nvme0n1p3    REST       Linux filesystem   /
```

**You choose:** Any swap size (2GB, 8GB, etc.) or none at all!

---

## 🎯 Key Improvements Summary

### **Simplified**
- ❌ No more WiFi wizard (connect before running)
- ❌ No more triple confirmation (just one)
- ❌ No mandatory swap partition
- ✅ Faster, more straightforward process

### **Enhanced**
- ✅ Flexible partition schemes (swap optional)
- ✅ Security features (firewall, fail2ban, apparmor)
- ✅ Better for modern systems (16GB+ RAM)
- ✅ Cleaner user experience

### **Maintained**
- ✅ All development tools (Java, Node, IDEs)
- ✅ All applications (Brave, Discord, Steam)
- ✅ Beautiful theming (Dark + Blue)
- ✅ GNOME extensions
- ✅ NVIDIA drivers (RTX 3060)

---

## 📊 Installation Time

| Phase | Time | User Input |
|-------|------|------------|
| Pre-Installation | 2-5 min | Language, disk, passwords |
| Automatic Install | 50-80 min | None (sit back!) |
| **Total** | **55-85 min** | **Minimal** |

---

## 🔧 Post-Installation

### **First Boot Checklist**
```bash
# 1. Enable firewall
sudo ufw enable

# 2. Update system
yay -Syu

# 3. Create Timeshift snapshot
sudo timeshift --create

# 4. Test NVIDIA
nvidia-smi

# 5. Check system info
fastfetch

# 6. Review security
cat ~/SECURITY-INFO.txt
```

---

## 💡 Pro Tips

### **No Swap? No Problem!**
With 16GB RAM, you likely won't need swap. If you do need it later:
```bash
# Create swapfile
sudo dd if=/dev/zero of=/swapfile bs=1M count=4096
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
```

### **Enable zram (Compressed RAM Swap)**
For even better performance without disk swap:
```bash
yay -S zram-generator
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service
```

---

## 🚀 Quick Command Reference

### **Before Installation (on Arch ISO)**
```bash
# Connect to WiFi
iwctl
station wlan0 connect YOUR_NETWORK

# Download installer
curl -L https://github.com/Trinitysudo/ElysiumArch/archive/main.tar.gz | tar xz
cd ElysiumArch-main

# Run installer
chmod +x install.sh
./install.sh
```

### **During Installation**
```
1. Select language
2. Choose timezone (auto-detected)
3. Pick keyboard layout
4. Set hostname (default: elysium-arch)
5. Create username
6. Set passwords (user + root)
7. Select disk
8. Choose partition scheme (1=no swap, 2=with swap, 3=custom)
9. Confirm
10. Wait 50-80 minutes
11. Reboot!
```

### **After Installation**
```bash
# Enable security
sudo ufw enable

# Update system
yay -Syu

# Backup
sudo timeshift --create

# System info
fastfetch
```

---

## 🎉 You're Done!

Your system now has:
- ✅ Arch Linux with GNOME
- ✅ Java 17 & 21 (for development)
- ✅ NVIDIA drivers (RTX 3060)
- ✅ All your apps (Brave, Discord, Steam, VSCode)
- ✅ Dark theme with blue accents
- ✅ Security configured (firewall, fail2ban, apparmor)
- ✅ Optional swap (your choice!)
- ✅ Ready for development and gaming!

**Enjoy your ElysiumArch system! 🚀**
