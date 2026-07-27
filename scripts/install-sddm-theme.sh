#!/usr/bin/env bash
#
#  Installs SilentSDDM (https://github.com/uiriansan/SilentSDDM)
#  and applies one of its bundled config presets.
#
#  Usage: ./install-sddm-theme.sh [preset]
#  Presets: default, rei, ken, silvia, everforest,
#           catppuccin-latte, catppuccin-frappe,
#           catppuccin-macchiato, catppuccin-mocha, nord
#
set -euo pipefail

PRESET="${1:-silvia}"

c_reset='\033[0m'; c_blue='\033[1;34m'; c_green='\033[1;32m'
info() { echo -e "${c_blue}[*]${c_reset} $1"; }
ok()   { echo -e "${c_green}[✓]${c_reset} $1"; }

info "Installing SilentSDDM dependencies..."
sudo pacman -S --needed --noconfirm \
    sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg qt6-imageformats git

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

info "Cloning SilentSDDM..."
git clone -b main --depth=1 https://github.com/uiriansan/SilentSDDM "$tmp/SilentSDDM"

info "Installing theme files to /usr/share/sddm/themes/silent..."
sudo mkdir -p /usr/share/sddm/themes/silent
sudo cp -rf "$tmp/SilentSDDM"/. /usr/share/sddm/themes/silent/

if [[ -d /usr/share/sddm/themes/silent/fonts ]]; then
    sudo cp -r /usr/share/sddm/themes/silent/fonts/* /usr/share/fonts/ 2>/dev/null || true
fi

info "Applying '${PRESET}' preset..."
if [[ -f "/usr/share/sddm/themes/silent/configs/${PRESET}.conf" ]]; then
    sudo sed -i "s|^ConfigFile=.*|ConfigFile=configs/${PRESET}.conf|" \
        /usr/share/sddm/themes/silent/metadata.desktop
else
    echo "Preset '${PRESET}.conf' not found in configs/, keeping default.conf"
fi

info "Writing /etc/sddm.conf.d/silent.conf..."
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/silent.conf > /dev/null <<EOF
[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard

[Theme]
Current=silent
EOF

sudo systemctl enable sddm.service

ok "SilentSDDM installed with the '${PRESET}' preset."
echo "Reboot to see the new login screen."
echo "If something looks broken, check: https://github.com/uiriansan/SilentSDDM/wiki"
