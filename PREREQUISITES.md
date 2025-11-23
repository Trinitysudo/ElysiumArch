# ElysiumArch Prerequisites & Requirements

## 🔧 System Requirements

### **Minimum Requirements**
- **CPU:** x86_64 processor (64-bit)
- **RAM:** 4GB (8GB recommended for smooth experience)
- **Storage:** 40GB free disk space (100GB+ recommended)
- **Boot Mode:** UEFI (required)
- **Internet:** Active internet connection (required)

### **Target/Optimized For**
- **CPU:** AMD Ryzen 5700X
- **GPU:** NVIDIA RTX 3060
- **RAM:** 16GB DDR4
- **Storage:** 500GB NVME SSD
- **Use Case:** Java Development & Gaming

---

## 📀 Pre-Installation Requirements

### **1. Download Arch Linux ISO**
Download the latest Arch Linux ISO from the official website:
- **Website:** https://archlinux.org/download/
- **Recommended:** Latest release (2024+)
- **Size:** ~800MB

### **2. Create Bootable USB**
Create a bootable USB drive using one of these tools:

**Windows:**
- Rufus (https://rufus.ie/)
- Balena Etcher (https://www.balena.io/etcher/)

**Linux:**
```bash
sudo dd if=archlinux.iso of=/dev/sdX bs=4M status=progress && sync
```

**macOS:**
```bash
sudo dd if=archlinux.iso of=/dev/diskX bs=1m
```

### **3. Boot Settings**
- Enable UEFI mode in BIOS
- Disable Secure Boot (if enabled)
- Set USB as first boot device

---

## 🌐 Internet Connection (CRITICAL!)

**YOU MUST CONNECT TO THE INTERNET BEFORE RUNNING THE INSTALLER!**

The installer does NOT configure WiFi for you. Follow these steps:

### **For Ethernet:**
Should work automatically. Test with:
```bash
ping archlinux.org
```

### **For WiFi:**
```bash
# Start iwctl
iwctl

# Inside iwctl:
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "YOUR_NETWORK_NAME"
exit

# Test connection
ping archlinux.org
```

### **Alternative WiFi Method:**
```bash
# Connect using nmcli
nmcli device wifi list
nmcli device wifi connect "SSID" password "PASSWORD"
```

---

## 📥 Installing ElysiumArch

### **Method 1: Bootstrap Script (Recommended)**
The bootstrap script automatically installs prerequisites and downloads ElysiumArch:

```bash
# Download and run bootstrap
curl -L https://raw.githubusercontent.com/Trinitysudo/ElysiumArch/main/bootstrap.sh | bash
```

The bootstrap script will:
- ✅ Check internet connection
- ✅ Sync system clock
- ✅ Install required tools (git, curl, wget)
- ✅ Download ElysiumArch installer
- ✅ Make scripts executable
- ✅ Offer to run the installer

### **Method 2: Manual Installation**

If the bootstrap script doesn't work or you prefer manual installation:

```bash
# 1. Update system clock
timedatectl set-ntp true

# 2. Install git (if not present)
pacman -Sy git

# 3. Clone the repository
git clone https://github.com/Trinitysudo/ElysiumArch.git
cd ElysiumArch

# 4. Make installer executable
chmod +x install.sh

# 5. Run the installer
./install.sh
```

### **Method 3: Download Tarball**
```bash
# 1. Install curl if needed
pacman -Sy curl

# 2. Download and extract
curl -L https://github.com/Trinitysudo/ElysiumArch/archive/main.tar.gz | tar xz
cd ElysiumArch-main

# 3. Make executable and run
chmod +x install.sh
./install.sh
```

---

## ⚠️ Important Pre-Installation Checklist

Before running the installer, ensure:

- [ ] **Internet connection is active and stable**
  ```bash
  ping -c 3 archlinux.org
  ```

- [ ] **Running as root**
  ```bash
  # If not root, switch to root:
  sudo su
  ```

- [ ] **UEFI mode is confirmed**
  ```bash
  # Check for UEFI:
  ls /sys/firmware/efi
  # Should show directory contents (not "No such file or directory")
  ```

- [ ] **Enough disk space available**
  ```bash
  # List disks and check size:
  lsblk
  fdisk -l
  ```

- [ ] **Backup any important data**
  The installer will FORMAT THE SELECTED DISK!
  ALL DATA WILL BE ERASED!

---

## 🔍 Troubleshooting Prerequisites

### **"No internet connection" Error**
```bash
# Check network interfaces
ip link

# For WiFi, ensure interface is up
ip link set wlan0 up

# Try DHCP
dhcpcd

# Test connection
ping archlinux.org
```

### **"Not running as root" Error**
```bash
# Switch to root
sudo su
# or
su

# Verify you're root
whoami
# Should output: root
```

### **"UEFI not detected" Warning**
- Reboot and enter BIOS/UEFI settings
- Enable UEFI mode
- Disable CSM/Legacy mode
- Save and reboot

### **"Command not found" Errors**
```bash
# Update package database
pacman -Sy

# Install missing tools
pacman -S git curl wget
```

### **Slow Download Speeds**
```bash
# Update mirrorlist for faster downloads
reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy
```

---

## 📊 Installation Space Requirements

| Component | Space Required |
|-----------|---------------|
| Base System | ~2GB |
| GNOME Desktop | ~3GB |
| Development Tools | ~5GB |
| Applications | ~8GB |
| NVIDIA Drivers | ~2GB |
| **Total (Minimum)** | **~20GB** |
| **Recommended** | **50GB+** |

---

## ⏱️ Estimated Installation Time

| Phase | Duration | Notes |
|-------|----------|-------|
| Pre-Installation Setup | 5-10 min | Network + config |
| Base System | 10-20 min | Depends on connection |
| Desktop Environment | 15-20 min | GNOME + drivers |
| Package Managers | 5-10 min | yay, paru, Homebrew |
| Development Tools | 20-30 min | Java, Node, IDEs |
| Applications | 30-40 min | Largest phase |
| Theming & Security | 15-20 min | Customization |
| **Total Time** | **60-90 min** | With good connection |

---

## 🆘 Getting Help

If you encounter issues with prerequisites:

1. **Check the FAQ** in the main README.md
2. **Review installation logs** in `logs/install.log`
3. **Open an issue** on GitHub with:
   - Error message
   - Output of `lsblk`, `ip link`, `uname -a`
   - Installation log if available

---

## ✅ Ready to Install?

Once all prerequisites are met:

```bash
# Run the bootstrap script
curl -L https://raw.githubusercontent.com/Trinitysudo/ElysiumArch/main/bootstrap.sh | bash

# Or run the installer directly
./install.sh
```

**Remember:** The installer is interactive and will guide you through each step!
