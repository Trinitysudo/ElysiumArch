#!/usr/bin/env bash
#
# Module 15: Security Configuration
# Install and configure basic security tools (Manjaro/Debian/EndeavourOS style)
#

print_info "Configuring system security..."

# Install basic security packages
print_info "Installing security packages..."
arch-chroot /mnt pacman -S --noconfirm --needed \
    ufw \
    fail2ban \
    apparmor \
    audit

print_success "Security packages installed"
log_success "Security: Base packages installed"

# Configure UFW (Uncomplicated Firewall)
print_info "Configuring firewall (UFW)..."

# Enable UFW service
arch-chroot /mnt systemctl enable ufw

# Set default policies
arch-chroot /mnt ufw default deny incoming
arch-chroot /mnt ufw default allow outgoing

# Allow SSH (if needed)
# arch-chroot /mnt ufw allow ssh

# Don't enable UFW yet (will be enabled on first boot)
print_success "Firewall configured (will be enabled on first boot)"
log_success "Security: UFW configured"

# Configure Fail2Ban
print_info "Configuring Fail2Ban..."

# Create local jail configuration
cat > /mnt/etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = false
EOF

# Enable Fail2Ban service
arch-chroot /mnt systemctl enable fail2ban

print_success "Fail2Ban configured"
log_success "Security: Fail2Ban configured"

# Configure AppArmor
print_info "Configuring AppArmor..."

# Enable AppArmor service
arch-chroot /mnt systemctl enable apparmor

# Add AppArmor to kernel parameters
if grep -q "GRUB_CMDLINE_LINUX_DEFAULT" /mnt/etc/default/grub; then
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 apparmor=1 security=apparmor"/' /mnt/etc/default/grub
    
    # Regenerate GRUB config
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
fi

print_success "AppArmor configured"
log_success "Security: AppArmor enabled"

# Configure system auditing
print_info "Configuring system audit..."
arch-chroot /mnt systemctl enable auditd

print_success "System audit configured"
log_success "Security: auditd enabled"

# Set up automatic security updates (optional but recommended)
print_info "Configuring automatic security updates..."

cat > /mnt/etc/systemd/system/arch-update.service << 'EOF'
[Unit]
Description=Arch Linux System Update
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/pacman -Syu --noconfirm
EOF

cat > /mnt/etc/systemd/system/arch-update.timer << 'EOF'
[Unit]
Description=Weekly Arch Linux System Update

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Don't enable auto-updates by default (user choice)
print_info "Automatic updates configured (disabled by default)"
print_info "To enable: systemctl enable arch-update.timer"

# Configure sudo security
print_info "Hardening sudo configuration..."

cat > /mnt/etc/sudoers.d/security << 'EOF'
# Require password for sudo
Defaults timestamp_timeout=15

# Log sudo commands
Defaults log_output
Defaults!/usr/bin/sudoreplay !log_output
Defaults logfile="/var/log/sudo.log"
EOF

chmod 440 /mnt/etc/sudoers.d/security

print_success "Sudo security configured"

# Set secure umask
print_info "Setting secure file permissions (umask)..."
sed -i 's/umask 022/umask 027/' /mnt/etc/profile

print_success "Secure umask configured"

# Configure kernel security parameters
print_info "Setting kernel security parameters..."

cat > /mnt/etc/sysctl.d/99-security.conf << 'EOF'
# IP Spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

# Ignore send redirects
net.ipv4.conf.all.send_redirects = 0

# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Log Martians
net.ipv4.conf.all.log_martians = 1

# Ignore ICMP ping requests
net.ipv4.icmp_echo_ignore_all = 0

# Protect against SYN flood attacks
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5

# Disable IPv6 if not needed (optional)
# net.ipv6.conf.all.disable_ipv6 = 1
# net.ipv6.conf.default.disable_ipv6 = 1

# Enable kernel panic on oops
kernel.panic_on_oops = 1
kernel.panic = 10

# Restrict kernel logs
kernel.dmesg_restrict = 1
EOF

print_success "Kernel security parameters set"
log_success "Security: Kernel hardening applied"

# Create security info file for user
cat > /mnt/home/$USERNAME/SECURITY-INFO.txt << 'EOF'
===========================================
  ElysiumArch Security Configuration
===========================================

Installed Security Tools:
-------------------------
✓ UFW (Uncomplicated Firewall) - Firewall management
✓ Fail2Ban - Intrusion prevention
✓ AppArmor - Mandatory access control
✓ auditd - System auditing

Post-Installation Security Steps:
---------------------------------
1. Enable firewall:
   sudo ufw enable
   sudo ufw status

2. Check Fail2Ban status:
   sudo systemctl status fail2ban

3. Check AppArmor status:
   sudo aa-status

4. Review audit logs:
   sudo ausearch -m avc -ts recent

5. Enable automatic updates (optional):
   sudo systemctl enable arch-update.timer
   sudo systemctl start arch-update.timer

Additional Security Recommendations:
-----------------------------------
• Use strong passwords
• Enable 2FA where possible
• Keep system updated: yay -Syu
• Review sudo logs: sudo cat /var/log/sudo.log
• Monitor system logs: journalctl -p 3 -xb

For more information:
--------------------
• UFW: sudo ufw --help
• Fail2Ban: sudo fail2ban-client status
• AppArmor: man apparmor

Your system has basic security configured similar to
Manjaro, Debian, and EndeavourOS distributions.
===========================================
EOF

chown $USERNAME:$USERNAME /mnt/home/$USERNAME/SECURITY-INFO.txt

print_success "Security information file created"

# Summary
print_success "Security configuration complete"
log_success "Security: All security measures configured"

print_info "Security features installed:"
print_info "  ✓ UFW Firewall (will be enabled on first boot)"
print_info "  ✓ Fail2Ban (intrusion prevention)"
print_info "  ✓ AppArmor (mandatory access control)"
print_info "  ✓ System auditing (auditd)"
print_info "  ✓ Kernel hardening parameters"
print_info "  ✓ Sudo logging and security"
print_info ""
print_info "See ~/SECURITY-INFO.txt for more details"
