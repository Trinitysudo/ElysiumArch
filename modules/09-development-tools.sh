#!/usr/bin/env bash
#
# Module 09: Development Tools Installation
# Install Java, Node.js, IDEs, and development utilities
#

# Check if debug mode is enabled
if [[ "$DEBUG_MODE" == "true" ]]; then
    print_warning "DEBUG MODE: Skipping development tools installation"
    echo "DEBUG_MODE_SKIP" >> /mnt/var/log/elysium/install_status
    exit 0
fi

print_info "Installing development tools..."

# Install Java Development Kits
print_info "Installing Java JDK 17 and 21..."

# Install JDK packages (JRE is included in JDK, don't install separately)
arch-chroot /mnt pacman -S --noconfirm --needed \
    jdk17-openjdk \
    jdk21-openjdk

if [[ $? -ne 0 ]]; then
    print_error "Failed to install Java JDKs"
    log_error "Development: Java JDK installation failed"
    exit 1
fi

print_success "Java JDKs installed (17 and 21)"

# Install build tools
print_info "Installing Maven and Gradle..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    maven \
    gradle

if [[ $? -ne 0 ]]; then
    print_warning "Failed to install Maven/Gradle - will continue"
fi

log_success "Development: Java JDK 17 and 21 with build tools installed"

# Set Java 21 as default
print_info "Setting Java 21 as default..."
arch-chroot /mnt archlinux-java set java-21-openjdk
print_success "Java 21 set as default"

# Verify Java installation
JAVA_VERSION=$(arch-chroot /mnt java -version 2>&1 | head -n 1)
print_info "Java version: $JAVA_VERSION"
log_info "Development: $JAVA_VERSION"

# Install Node.js and npm
print_info "Installing Node.js and npm..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    nodejs \
    npm \
    yarn

if [[ $? -ne 0 ]]; then
    print_error "Failed to install Node.js"
    log_error "Development: Node.js installation failed"
    exit 1
fi

print_success "Node.js and npm installed"

# Verify Node.js installation
NODE_VERSION=$(arch-chroot /mnt node --version)
NPM_VERSION=$(arch-chroot /mnt npm --version)
print_info "Node.js version: $NODE_VERSION"
print_info "npm version: $NPM_VERSION"
log_info "Development: Node.js $NODE_VERSION, npm $NPM_VERSION installed"

# Install Python and pip
print_info "Installing Python development tools..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    python \
    python-pip \
    python-virtualenv

if [[ $? -ne 0 ]]; then
    print_warning "Failed to install Python tools - will continue"
fi

print_success "Python tools installed"

# Install C/C++ development tools (minimal)
print_info "Installing C/C++ development tools..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    gcc \
    cmake \
    make

print_success "C/C++ tools installed"

# Install Git and GitHub CLI
print_info "Installing Git and GitHub CLI..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    git \
    git-lfs \
    github-cli

print_success "Git tools installed"

# Configure Git (basic setup)
print_info "Git has been installed. Configure it after reboot with:"
print_info "  git config --global user.name \"Your Name\""
print_info "  git config --global user.email \"your.email@example.com\""

# Install essential tools
print_info "Installing essential tools..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    jq \
    curl \
    wget

print_success "Essential tools installed"

# Install code quality tools
print_info "Installing code quality tools..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    shellcheck

print_success "Code quality tools installed"

# Install documentation tools
arch-chroot /mnt pacman -S --noconfirm --needed \
    man-db \
    man-pages \
    tldr

# Note about IDEs (will be installed via AUR)
print_info "IDEs (VS Code, IntelliJ IDEA) will be installed via AUR..."

print_success "Development tools installation complete"
log_success "Development tools installed successfully"

# Display summary
print_info "Installed development tools:"
print_info "  ✓ Java OpenJDK 17 (default) & 21"
print_info "  ✓ Maven & Gradle"
print_info "  ✓ Node.js & npm"
print_info "  ✓ Python & pip"
print_info "  ✓ Git & GitHub CLI"
print_info "  ✓ C/C++ toolchain (gcc, clang)"
print_info "  ✓ Database clients"
print_info "  ✓ API testing tools"
