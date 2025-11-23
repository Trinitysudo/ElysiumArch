#!/usr/bin/env bash
#
# Module 02: Localization Configuration
# Configure language, timezone, and keyboard layout
#

print_info "Configuring localization settings..."

# Language selection
print_info "Select your language:"
echo "1) English (US)"
echo "2) English (UK)"
echo "3) Spanish"
echo "4) French"
echo "5) German"
echo "6) Italian"
echo "7) Portuguese"
echo "8) Other"

read -p "Select language [1-8] (default: 1): " lang_choice
lang_choice=${lang_choice:-1}

case $lang_choice in
    1) LOCALE="en_US.UTF-8" ;;
    2) LOCALE="en_GB.UTF-8" ;;
    3) LOCALE="es_ES.UTF-8" ;;
    4) LOCALE="fr_FR.UTF-8" ;;
    5) LOCALE="de_DE.UTF-8" ;;
    6) LOCALE="it_IT.UTF-8" ;;
    7) LOCALE="pt_BR.UTF-8" ;;
    8) 
        read -p "Enter locale (e.g., ja_JP.UTF-8): " LOCALE
        ;;
    *) 
        LOCALE="en_US.UTF-8"
        print_warning "Invalid choice, using default: en_US.UTF-8"
        ;;
esac

export LOCALE
print_success "Locale set to: $LOCALE"
log_info "Localization: Locale set to $LOCALE"

# Timezone selection
print_info "Detecting timezone..."
DETECTED_TZ=$(curl -s http://ip-api.com/line?fields=timezone 2>/dev/null)

if [[ -n "$DETECTED_TZ" ]]; then
    print_info "Detected timezone: $DETECTED_TZ"
    if confirm "Use detected timezone?"; then
        TIMEZONE="$DETECTED_TZ"
    else
        read -p "Enter timezone (e.g., America/New_York): " TIMEZONE
    fi
else
    print_info "Common timezones:"
    echo "  America/New_York (EST)"
    echo "  America/Chicago (CST)"
    echo "  America/Denver (MST)"
    echo "  America/Los_Angeles (PST)"
    echo "  Europe/London"
    echo "  Europe/Paris"
    echo "  Asia/Tokyo"
    read -p "Enter timezone: " TIMEZONE
fi

# Validate timezone
if [[ ! -f "/usr/share/zoneinfo/$TIMEZONE" ]]; then
    print_warning "Timezone not found, using UTC"
    TIMEZONE="UTC"
fi

export TIMEZONE
print_success "Timezone set to: $TIMEZONE"
log_info "Localization: Timezone set to $TIMEZONE"

# Keyboard layout
print_info "Select keyboard layout:"
echo "1) US (default)"
echo "2) UK"
echo "3) German"
echo "4) French"
echo "5) Spanish"
echo "6) Other"

read -p "Select keyboard layout [1-6] (default: 1): " kb_choice
kb_choice=${kb_choice:-1}

case $kb_choice in
    1) KEYMAP="us" ;;
    2) KEYMAP="uk" ;;
    3) KEYMAP="de" ;;
    4) KEYMAP="fr" ;;
    5) KEYMAP="es" ;;
    6) 
        read -p "Enter keymap (e.g., dvorak): " KEYMAP
        ;;
    *) 
        KEYMAP="us"
        print_warning "Invalid choice, using default: us"
        ;;
esac

# Apply keyboard layout
loadkeys "$KEYMAP" 2>/dev/null
export KEYMAP
print_success "Keyboard layout set to: $KEYMAP"
log_info "Localization: Keyboard layout set to $KEYMAP"

# Hostname
print_info "Set hostname for your system:"
read -p "Enter hostname (default: elysium-arch): " HOSTNAME
HOSTNAME=${HOSTNAME:-elysium-arch}
export HOSTNAME
print_success "Hostname set to: $HOSTNAME"
log_info "Localization: Hostname set to $HOSTNAME"

# Username
print_info "Create user account:"
read -p "Enter username: " USERNAME
while [[ -z "$USERNAME" ]]; do
    print_error "Username cannot be empty"
    read -p "Enter username: " USERNAME
done
export USERNAME
export INSTALL_USER="$USERNAME"

# Password
while true; do
    read -sp "Enter password for $USERNAME: " USER_PASSWORD
    echo ""
    read -sp "Confirm password: " USER_PASSWORD2
    echo ""
    
    if [[ "$USER_PASSWORD" == "$USER_PASSWORD2" ]]; then
        export USER_PASSWORD
        break
    else
        print_error "Passwords do not match, try again"
    fi
done

print_success "User account configured: $USERNAME"
log_info "Localization: User account created for $USERNAME"

# Root password
print_info "Set root password:"
while true; do
    read -sp "Enter root password: " ROOT_PASSWORD
    echo ""
    read -sp "Confirm root password: " ROOT_PASSWORD2
    echo ""
    
    if [[ "$ROOT_PASSWORD" == "$ROOT_PASSWORD2" ]]; then
        export ROOT_PASSWORD
        break
    else
        print_error "Passwords do not match, try again"
    fi
done

print_success "Root password configured"
log_success "Localization configuration complete"
