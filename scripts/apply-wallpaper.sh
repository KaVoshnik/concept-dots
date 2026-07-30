#!/usr/bin/env bash
#
#  apply-wallpaper.sh <path-to-image>
#
#  Switches the live wallpaper (auto-detects awww or swww — see
#  init-wallpaper.sh for why) and updates the "current" symlink that
#  hyprlock/fastfetch point at, so lockscreen + terminal splash stay
#  in sync with whatever's on the desktop.
#
set -euo pipefail

WALL_DIR="$HOME/.config/hypr/wallpapers"
CURRENT_LINK="$WALL_DIR/current.png"

if [[ $# -ne 1 || ! -f "$1" ]]; then
    echo "Usage: apply-wallpaper.sh <path-to-image>"
    exit 1
fi

TARGET="$(realpath "$1")"

if command -v awww-daemon >/dev/null 2>&1; then
    BIN=awww
elif command -v swww-daemon >/dev/null 2>&1; then
    BIN=swww
else
    echo "apply-wallpaper.sh: neither awww nor swww is installed (try: sudo pacman -S awww)" >&2
    exit 1
fi

if ! pgrep -x "${BIN}-daemon" >/dev/null; then
    "${BIN}-daemon" &
fi

for _ in $(seq 1 25); do
    if "$BIN" query >/dev/null 2>&1; then
        break
    fi
    sleep 0.2
done

"$BIN" img "$TARGET" \
    --transition-type wipe \
    --transition-fps 60 \
    --transition-duration 0.7

ln -sfn "$TARGET" "$CURRENT_LINK"

echo "Wallpaper set to $TARGET (via $BIN)"
