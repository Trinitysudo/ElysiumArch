# ElysiumArch Quick Start

## Automated Installation (No Prompts!)

1. **Edit `config.sh`** with your preferences:
```bash
nano config.sh
```

Set your:
- `USERNAME` - Your username
- `USER_PASSWORD` - Your password  
- `ROOT_PASSWORD` - Root password
- `TIMEZONE` - Your timezone (optional)
- `SKIP_PARU` - Set to 1 to skip paru (optional)
- `SKIP_HOMEBREW` - Set to 1 to skip Homebrew (optional)

2. **Run the installer:**
```bash
./install.sh
```

That's it! No more prompts for username/password - it's all automatic!

## Manual Installation (With Prompts)

If you don't edit `config.sh`, the installer will prompt you for:
- Username
- Password
- Root password

## Resume Installation

If installation is interrupted, just run `./install.sh` again. It will:
- Resume from the last completed module
- Use your saved configuration (no re-prompting)

## Configuration File

The `config.sh` file contains all your preferences. Edit it before running to avoid any prompts:

```bash
USERNAME="drew"              # Change this
USER_PASSWORD="a"            # Change this  
ROOT_PASSWORD="root123"      # Change this
TIMEZONE="America/New_York"  # Optional
SKIP_PARU=0                  # 0=install, 1=skip
SKIP_HOMEBREW=0              # 0=install, 1=skip
```

## Features

- ✅ **Zero prompts** when config.sh is configured
- ✅ **Resume capability** if interrupted
- ✅ **Checkpoint system** tracks completed modules
- ✅ **Universal GPU support** (NVIDIA/AMD/Intel/VM)
- ✅ **First-boot report** shows installation status
- ✅ **Gaming ready** with 32-bit libraries

Enjoy your automated Arch installation! 🚀
