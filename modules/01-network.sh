#!/usr/bin/env bash
#
# Module 01: Network Configuration
# Verify internet connectivity (assumes user already connected)
#

print_info "Verifying network connectivity..."

# Check if already connected
if ping -c 1 archlinux.org &>/dev/null; then
    print_success "Internet connection verified"
    log_success "Network: Internet connection active"
else
    print_error "No internet connection detected!"
    print_error "Please connect to the internet before running this installer."
    print_info "For WiFi, use: iwctl"
    print_info "  1. iwctl"
    print_info "  2. station wlan0 scan"
    print_info "  3. station wlan0 connect YOUR_SSID"
    log_error "Network: No internet connection"
    exit 1
fi

# Sync system clock
print_info "Synchronizing system clock..."
timedatectl set-ntp true
if [[ $? -eq 0 ]]; then
    print_success "System clock synchronized"
    log_success "Network: System clock synchronized"
else
    print_warning "Failed to sync clock, continuing anyway..."
    log_warning "Network: Clock sync failed"
fi

# Test connection one more time
print_info "Testing internet connection..."
if ping -c 3 archlinux.org &>/dev/null; then
    print_success "Internet connection verified"
    log_success "Network: Connection test successful"
else
    print_error "Internet connection test failed"
    print_error "Cannot proceed without internet"
    log_error "Network: Connection test failed"
    exit 1
fi

print_success "Network configuration complete"
log_success "Network configuration completed successfully"
