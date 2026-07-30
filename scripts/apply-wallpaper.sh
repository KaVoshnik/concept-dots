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

# Ask the daemon directly rather than pgrep-ing for a process name — if a
# daemon is already reachable, don't spawn a second one. Starting a *new*
# daemon instance restores its last-cached wallpaper per output shortly
# after connecting, which would silently override whatever we're about
# to set here a second later. --no-cache also disables that behavior
# outright, as a second layer of protection.
if ! "$BIN" query >/dev/null 2>&1; then
    "${BIN}-daemon" --no-cache &
    for _ in $(seq 1 25); do
        if "$BIN" query >/dev/null 2>&1; then
            break
        fi
        sleep 0.2
    done
fi

"$BIN" img "$TARGET" \
    --transition-type wipe \
    --transition-fps 60 \
    --transition-duration 0.7

ln -sfn "$TARGET" "$CURRENT_LINK"

echo "Wallpaper set to $TARGET (via $BIN)"
