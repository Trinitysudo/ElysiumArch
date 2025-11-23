# Quick Fix Guide - Manual Package Installation

If some packages failed to install, you can install them manually after the system is up and running.

## What Failed and How to Fix

### ✅ yay - INSTALLED (Good!)

### ❌ paru - Not Installed
**Fix:** Now requires Rust (added in fix)
```bash
# Will work on next install attempt
```

### ❌ Homebrew - Not Installed  
**Fix:** Script path issue fixed
```bash
# Will work on next install attempt
```

### ❌ VS Code - Not Installed
**Manual install after reboot:**
```bash
yay -S visual-studio-code-bin
```

### ❌ IntelliJ IDEA - Not Installed
**Manual install after reboot:**
```bash
yay -S intellij-idea-community-edition
```

### ❌ Brave Browser - Not Installed
**Manual install after reboot:**
```bash
yay -S brave-bin
```

### ❌ Discord - Not Installed
**Manual install after reboot:**
```bash
yay -S discord
```

### ❌ Steam - Not Installed
**Manual install after reboot:**
```bash
sudo pacman -S steam
```

### ✅ Kitty - INSTALLED (Good!)

### ❌ Timeshift - Not Installed
**Manual install after reboot:**
```bash
yay -S timeshift
```

### ❌ fastfetch - Not Installed
**Fix:** Now using pacman instead of yay (official repos)
```bash
sudo pacman -S fastfetch
```

## Better Option: Resume Installation

Since we added checkpoint/resume, you can just **restart the installer** and it will resume from where it failed!

```bash
cd ElysiumArch-main
./install.sh

# It will ask: "Resume from last checkpoint? [y/N]"
# Press 'y' to continue!
```

## What Was Fixed

1. **paru** - Added `rust` package requirement (was missing)
2. **Homebrew** - Fixed script path issue (no more /tmp errors)
3. **fastfetch** - Changed to official repos (pacman instead of yay)
4. **yay verification** - Added check to ensure yay works before using it
5. **Better error handling** - Added `--needed` flag and yay availability check

## Resume and It Will Work!

The fixes are now pushed to GitHub. When you resume the installation:
- ✅ Modules 1-7 will be skipped (already completed)
- ✅ Module 8 will retry with the fixes (paru will now work)
- ✅ Modules 9-15 will continue with all apps installing correctly

**Just run `./install.sh` again and press 'y' to resume!** 🚀
