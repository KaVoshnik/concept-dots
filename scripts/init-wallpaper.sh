#!/usr/bin/env bash
#
#  init-wallpaper.sh — starts the wallpaper daemon (if not already
#  running) and waits for its IPC socket before setting the wallpaper.
#  Called once from hyprland.conf's exec-once.
#
#  Auto-detects `awww` (the current package name — swww was renamed
#  upstream) or `swww` (older installs / in case it gets renamed back),
#  so this doesn't need editing every time upstream shuffles names again.
#
set -euo pipefail

WALLPAPER="$HOME/.config/hypr/wallpapers/current.png"

if command -v awww-daemon >/dev/null 2>&1; then
    BIN=awww
elif command -v swww-daemon >/dev/null 2>&1; then
    BIN=swww
else
    echo "init-wallpaper.sh: neither awww nor swww is installed (try: sudo pacman -S awww)" >&2
    exit 1
fi

if ! pgrep -x "${BIN}-daemon" >/dev/null; then
    "${BIN}-daemon" &
fi

# wait up to ~5s for the daemon's socket to be ready
for _ in $(seq 1 25); do
    if "$BIN" query >/dev/null 2>&1; then
        break
    fi
    sleep 0.2
done

if [[ -e "$WALLPAPER" ]]; then
    "$BIN" img "$WALLPAPER" --transition-type wipe --transition-fps 60 --transition-duration 0.7
else
    echo "init-wallpaper.sh: $WALLPAPER not found, skipping" >&2
fi
