#!/usr/bin/env bash
#
#  apply-wallpaper.sh <path-to-image>
#
#  Switches the live wallpaper via swww and updates the "current" symlink
#  that hyprlock/fastfetch point at, so lockscreen + terminal splash stay
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

if ! pgrep -x swww-daemon >/dev/null; then
    swww-daemon &
    sleep 0.5
fi

swww img "$TARGET" \
    --transition-type wipe \
    --transition-fps 60 \
    --transition-duration 0.7

ln -sfn "$TARGET" "$CURRENT_LINK"

echo "Wallpaper set to $TARGET"
