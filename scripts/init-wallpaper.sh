#!/usr/bin/env bash
#
#  init-wallpaper.sh — starts swww-daemon (if not already running) and
#  waits for its IPC socket before setting the wallpaper. Called once
#  from hyprland.conf's exec-once; avoids the race where `swww img`
#  fires before the daemon has finished coming up.
#
set -euo pipefail

WALLPAPER="$HOME/.config/hypr/wallpapers/current.png"

if ! pgrep -x swww-daemon >/dev/null; then
    swww-daemon &
fi

# wait up to ~5s for the daemon's socket to be ready
for _ in $(seq 1 25); do
    if swww query >/dev/null 2>&1; then
        break
    fi
    sleep 0.2
done

if [[ -e "$WALLPAPER" ]]; then
    swww img "$WALLPAPER" --transition-type wipe --transition-fps 60 --transition-duration 0.7
else
    echo "init-wallpaper.sh: $WALLPAPER not found, skipping" >&2
fi
