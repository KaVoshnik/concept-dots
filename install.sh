#!/usr/bin/env bash
#
#  concept-dots installer
#  minimalist Hyprland setup for CachyOS / Arch-based distros
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

c_reset='\033[0m'; c_blue='\033[1;34m'; c_green='\033[1;32m'; c_yellow='\033[1;33m'; c_red='\033[1;31m'

info()  { echo -e "${c_blue}[*]${c_reset} $1"; }
ok()    { echo -e "${c_green}[✓]${c_reset} $1"; }
warn()  { echo -e "${c_yellow}[!]${c_reset} $1"; }
fail()  { echo -e "${c_red}[x]${c_reset} $1"; exit 1; }

echo -e "${c_blue}"
cat <<'EOF'
  ___ ___  _  _  ___ ___ ___ _____
 / __/ _ \| \| |/ __| __| _ \_   _|
| (_| (_) | .` | (__| _||  _/ | |
 \___\___/|_|\_|\___|___|_|   |_|

  minimal hyprland dotfiles for CachyOS
EOF
echo -e "${c_reset}"

# ── sanity checks ──
if [[ "$EUID" -eq 0 ]]; then
    fail "Don't run this script as root."
fi

if ! command -v pacman &>/dev/null; then
    fail "This installer targets Arch-based distros (CachyOS). pacman not found."
fi

# ── install paru if missing (AUR helper) ──
if ! command -v paru &>/dev/null; then
    info "paru not found, building it from AUR..."
    sudo pacman -S --needed --noconfirm base-devel git
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/paru.git "$tmp/paru"
    (cd "$tmp/paru" && makepkg -si --noconfirm)
    rm -rf "$tmp"
    ok "paru installed"
else
    ok "paru already installed"
fi

# ── package list ──
PACMAN_PKGS=(
    hyprland hyprpaper hypridle hyprlock
    waybar rofi-wayland dunst wlogout
    kitty fish starship fastfetch
    grim slurp wl-clipboard cliphist hyprpicker
    playerctl brightnessctl networkmanager network-manager-applet
    polkit-kde-agent papirus-icon-theme
    ttf-jetbrains-mono-nerd
    eza bat ripgrep zoxide fzf fd
    nautilus pavucontrol
    xdg-desktop-portal-hyprland
    qt5ct qt6ct
)

AUR_PKGS=(
    bibata-cursor-theme-bin
)

info "Installing official repo packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
ok "Official packages installed"

info "Installing AUR packages..."
paru -S --needed --noconfirm "${AUR_PKGS[@]}"
ok "AUR packages installed"

# ── backup existing config ──
if [[ -d "$CONFIG_DIR" ]]; then
    info "Backing up existing ~/.config to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    for dir in hypr waybar rofi kitty fish dunst wlogout fastfetch starship.toml; do
        if [[ -e "$CONFIG_DIR/$dir" ]]; then
            mv "$CONFIG_DIR/$dir" "$BACKUP_DIR/"
        fi
    done
    ok "Backup complete"
fi

# ── symlink configs ──
info "Linking configs into ~/.config..."
mkdir -p "$CONFIG_DIR"
for dir in hypr waybar rofi kitty fish dunst wlogout fastfetch; do
    ln -sfn "$REPO_DIR/.config/$dir" "$CONFIG_DIR/$dir"
done
ln -sf "$REPO_DIR/.config/starship.toml" "$CONFIG_DIR/starship.toml"
ok "Configs linked"

# ── wallpapers ──
mkdir -p "$REPO_DIR/.config/hypr/wallpapers"
if [[ ! -f "$REPO_DIR/.config/hypr/wallpapers/default.png" ]]; then
    warn "No default wallpaper found — drop one at .config/hypr/wallpapers/default.png"
fi

# ── fisher + plugins for fish ──
if command -v fish &>/dev/null; then
    info "Installing Fisher and fish plugins..."
    fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher' || true
    fish -c 'fisher update' || true
    ok "Fish plugins installed"
fi

# ── set fish as default shell ──
if [[ "$SHELL" != *fish* ]]; then
    info "Setting fish as default shell..."
    chsh -s "$(which fish)" "$USER"
    ok "Default shell changed to fish (re-login to apply)"
fi

echo
ok "All done! Reboot or re-login, then select Hyprland at your display manager."
warn "Don't forget to edit .config/hypr/monitors.conf for your screen setup."
