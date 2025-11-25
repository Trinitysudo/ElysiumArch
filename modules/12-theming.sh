#!/usr/bin/env bash
#
# Module 12: Theming - DISABLED (ML4W Dotfiles handle everything)
# ML4W dotfiles include complete theming: Waybar, Rofi, wallpapers, icons, etc.
#

print_info "Skipping custom theming - ML4W Dotfiles handle all theming..."
print_success "ML4W Dotfiles provide complete professional theme system"
log_success "Theming: Using ML4W Dotfiles (no custom theming needed)"

# Exit successfully - nothing to do here
exit 0

# OLD CODE DISABLED - ML4W handles everything
# Download Arch Linux wallpapers
print_info "Downloading Arch Linux wallpapers..."
mkdir -p /mnt/home/$USERNAME/Pictures/wallpapers
arch-chroot /mnt sudo -u $USERNAME bash << 'WALLPAPER_EOF'
cd ~/Pictures/wallpapers
# Download amazing Arch wallpapers
curl -L "https://raw.githubusercontent.com/archlinux/archlinux-artwork/master/wallpaper/archlinux-simplyblack.png" -o arch-black.png 2>/dev/null || true
curl -L "https://wallpapercave.com/uwp/uwp4923981.jpeg" -o arch-blue-1.jpg 2>/dev/null || true

# Create symlink to default wallpaper
ln -sf ~/Pictures/wallpapers/arch-black.png ~/Pictures/wallpaper.png || cp ~/Pictures/wallpapers/arch-black.png ~/Pictures/wallpaper.png
WALLPAPER_EOF

print_success "Arch wallpapers downloaded"

# Configure Waybar (blue/black theme)
print_info "Configuring Waybar with blue/black theme..."
mkdir -p /mnt/home/$USERNAME/.config/waybar

cat > /mnt/home/$USERNAME/.config/waybar/config << 'WAYBAR_CONFIG_EOF'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "spacing": 4,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["hyprland/window"],
    "modules-right": ["pulseaudio", "network", "cpu", "memory", "temperature", "battery", "clock", "tray"],
    
    "hyprland/workspaces": {
        "format": "{icon}",
        "on-click": "activate",
        "format-icons": {
            "1": "",
            "2": "",
            "3": "",
            "4": "",
            "5": "",
            "urgent": "",
            "active": "",
            "default": ""
        }
    },
    "hyprland/window": {
        "format": "{}",
        "max-length": 50
    },
    "clock": {
        "format": " {:%H:%M   %d/%m/%Y}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },
    "cpu": {
        "format": " {usage}%",
        "tooltip": false
    },
    "memory": {
        "format": " {}%"
    },
    "temperature": {
        "critical-threshold": 80,
        "format": "{icon} {temperatureC}°C",
        "format-icons": ["", "", ""]
    },
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-charging": " {capacity}%",
        "format-plugged": " {capacity}%",
        "format-icons": ["", "", "", "", ""]
    },
    "network": {
        "format-wifi": " {essid}",
        "format-ethernet": " {ipaddr}/{cidr}",
        "format-disconnected": "⚠ Disconnected",
        "tooltip-format": "{ifname} via {gwaddr}"
    },
    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": " Muted",
        "format-icons": {
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    },
    "tray": {
        "spacing": 10
    }
}
WAYBAR_CONFIG_EOF

cat > /mnt/home/$USERNAME/.config/waybar/style.css << 'WAYBAR_STYLE_EOF'
* {
    border: none;
    border-radius: 0;
    font-family: "JetBrainsMono Nerd Font";
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background-color: rgba(30, 30, 46, 0.85);
    color: #cdd6f4;
    transition-property: background-color;
    transition-duration: .5s;
}

#workspaces button {
    padding: 0 8px;
    color: #89b4fa;
    background-color: transparent;
    border-bottom: 3px solid transparent;
}

#workspaces button.active {
    background-color: rgba(137, 180, 250, 0.3);
    border-bottom: 3px solid #89b4fa;
}

#workspaces button:hover {
    background-color: rgba(137, 180, 250, 0.2);
}

#clock,
#battery,
#cpu,
#memory,
#temperature,
#network,
#pulseaudio,
#tray {
    padding: 0 10px;
    color: #cdd6f4;
}

#window {
    color: #89b4fa;
    font-weight: bold;
}

#battery.charging {
    color: #a6e3a1;
}

#battery.warning:not(.charging) {
    color: #f9e2af;
}

#battery.critical:not(.charging) {
    color: #f38ba8;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

@keyframes blink {
    to {
        background-color: rgba(243, 139, 168, 0.3);
        color: #1e1e2e;
    }
}
WAYBAR_STYLE_EOF

print_success "Waybar configured with blue/black theme"

# Configure rofi (blue theme)
print_info "Configuring rofi launcher..."
mkdir -p /mnt/home/$USERNAME/.config/rofi

cat > /mnt/home/$USERNAME/.config/rofi/config.rasi << 'ROFI_EOF'
configuration {
    modi: "drun,run,window";
    show-icons: true;
    font: "JetBrainsMono Nerd Font 12";
    display-drun: " Apps";
    display-run: " Run";
    display-window: " Windows";
}

* {
    bg: #1e1e2edd;
    bg-alt: #45475add;
    fg: #cdd6f4;
    fg-alt: #89b4fa;
    blue: #89b4fa;
    
    background-color: @bg;
    text-color: @fg;
}

window {
    width: 40%;
    border: 2px;
    border-color: @blue;
    border-radius: 10px;
}

mainbox {
    padding: 20px;
}

inputbar {
    children: [prompt, entry];
    padding: 10px;
    border-radius: 5px;
    background-color: @bg-alt;
}

prompt {
    text-color: @blue;
    padding: 0 10px 0 0;
}

entry {
    text-color: @fg;
}

listview {
    lines: 8;
    scrollbar: false;
}

element {
    padding: 8px;
    border-radius: 5px;
}

element selected {
    background-color: @bg-alt;
    text-color: @blue;
}

element-icon {
    size: 24px;
}

element-text {
    text-color: inherit;
}
ROFI_EOF

print_success "Rofi configured with blue theme"

# Configure dunst (notifications)
print_info "Configuring dunst notifications..."
mkdir -p /mnt/home/$USERNAME/.config/dunst

cat > /mnt/home/$USERNAME/.config/dunst/dunstrc << 'DUNST_EOF'
[global]
    font = JetBrainsMono Nerd Font 11
    corner_radius = 10
    frame_width = 2
    gap_size = 4
    padding = 12
    horizontal_padding = 12
    offset = 10x30
    
[urgency_low]
    background = "#1e1e2edd"
    foreground = "#cdd6f4"
    frame_color = "#89b4fa"
    timeout = 5

[urgency_normal]
    background = "#1e1e2edd"
    foreground = "#cdd6f4"
    frame_color = "#89b4fa"
    timeout = 10

[urgency_critical]
    background = "#1e1e2edd"
    foreground = "#f38ba8"
    frame_color = "#f38ba8"
    timeout = 0
DUNST_EOF

print_success "Dunst configured"

chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME/.config
chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME/Pictures

print_success "Blue/black Hyprland theme applied with Arch wallpapers!"
log_success "Theming: Blue/black theme with Arch backgrounds configured"
