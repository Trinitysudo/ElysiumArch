#!/usr/bin/env bash
#
# Module 09: Development Tools Installation
# Install Java, Node.js, IDEs, and development utilities
#

print_info "Installing development tools..."

# Install Java Development Kits
print_info "Installing Java JDK 17 and 21..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    jdk17-openjdk \
    jdk21-openjdk \
    jre17-openjdk \
    jre21-openjdk \
    maven \
    gradle

print_success "Java JDKs installed"
log_success "Development: Java JDK 17 and 21 installed"

# Set Java 17 as default
print_info "Setting Java 17 as default..."
arch-chroot /mnt archlinux-java set java-17-openjdk
print_success "Java 17 set as default"

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

print_success "Python tools installed"

# Install C/C++ development tools
print_info "Installing C/C++ development tools..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    gcc \
    g++ \
    clang \
    cmake \
    make \
    gdb \
    valgrind

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

# Install database clients
print_info "Installing database clients..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    postgresql-libs \
    mariadb-clients

print_success "Database clients installed"

# Install API testing tools
print_info "Installing API testing tools..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    httpie \
    jq \
    curl \
    wget

print_success "API tools installed"

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
