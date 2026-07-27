#!/usr/bin/env bash
#
#  Installs Elegant-grub2-themes
#  (https://github.com/vinceliuice/Elegant-grub2-themes)
#
#  Defaults: forest / window / left / dark / 1080p
#  Edit the flags below to change theme, style, side, color, or resolution.
#  Full option list: https://github.com/vinceliuice/Elegant-grub2-themes#usage
#
set -euo pipefail

c_reset='\033[0m'; c_blue='\033[1;34m'; c_green='\033[1;32m'; c_yellow='\033[1;33m'
info() { echo -e "${c_blue}[*]${c_reset} $1"; }
ok()   { echo -e "${c_green}[✓]${c_reset} $1"; }
warn() { echo -e "${c_yellow}[!]${c_reset} $1"; }

if ! command -v grub-mkconfig &>/dev/null && ! command -v grub2-mkconfig &>/dev/null; then
    warn "GRUB not detected on this system (CachyOS may default to systemd-boot/rEFInd). Skipping."
    warn "If you do use GRUB, make sure it's installed and on PATH, then re-run this script."
    exit 0
fi

sudo pacman -S --needed --noconfirm git

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

info "Cloning Elegant-grub2-themes..."
git clone --depth=1 https://github.com/vinceliuice/Elegant-grub2-themes.git "$tmp/Elegant-grub2-themes"

info "Installing theme (forest / window / left / dark / 1080p)..."
(cd "$tmp/Elegant-grub2-themes" && sudo ./install.sh -t forest -p window -i left -c dark -s 1080p)

ok "Elegant GRUB2 theme installed. It will show up on next reboot."
echo "Want a different variant? Re-run manually, e.g.:"
echo "  sudo ./install.sh -t wave -p blur -c dark -s 2k"
