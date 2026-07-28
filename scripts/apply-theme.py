#!/usr/bin/env python3
"""
apply-theme.py — regenerates the color blocks in every themed config file
from a single palette definition, then reloads the running apps that can
be reloaded live.

Usage:
    apply-theme.py <theme-name>
    apply-theme.py --list

Add a new theme by adding an entry to THEMES below — every file listed in
TARGETS will pick it up automatically, no other file needs touching.
"""
import re
import subprocess
import sys
from pathlib import Path

CONFIG = Path.home() / ".config"

# ── palettes ──────────────────────────────────────────────────────────
# keys are semantic slots, not literal color names — "lavender" is just
# "primary accent", "rosewater" is "secondary accent", etc. red/green/
# yellow are kept stable across themes since they carry meaning (errors,
# success...); only accent identity colors change per theme.
THEMES = {
    "concept": {
        "base": "101014", "mantle": "0a0a0c", "surface0": "1c1c24",
        "surface1": "272733", "overlay": "47475c", "muted": "72758c",
        "text": "e8e8ec", "subtext": "a3a3b0",
        "lavender": "8a90f0", "rosewater": "e8a0c8", "cyan": "35a8b4",
        "peach": "f0a878", "red": "f0645c", "green": "7cbd82", "yellow": "e8c48a",
    },
    "aurora": {
        "base": "101014", "mantle": "0a0a0c", "surface0": "1c1c24",
        "surface1": "272733", "overlay": "47475c", "muted": "72758c",
        "text": "e8e8ec", "subtext": "a3a3b0",
        "lavender": "f0a84a", "rosewater": "7ce0c0", "cyan": "4ab4f0",
        "peach": "f08c54", "red": "f0645c", "green": "7cbd82", "yellow": "e8c48a",
    },
}


def hx(theme, key):
    return theme[key]


def replace_block(path: Path, new_body: str, begin="BEGIN CONCEPT-THEME", end="END CONCEPT-THEME"):
    lines = path.read_text().splitlines(keepends=True)
    start_idx = next((i for i, l in enumerate(lines) if begin in l), None)
    end_idx = next((i for i, l in enumerate(lines) if end in l and (start_idx is None or i > start_idx)), None)
    if start_idx is None or end_idx is None:
        print(f"  ! markers not found in {path}, skipping")
        return
    nl = "\n" if not new_body.endswith("\n") else ""
    new_lines = lines[: start_idx + 1] + [new_body + nl] + lines[end_idx:]
    path.write_text("".join(new_lines))
    print(f"  ✓ {path.relative_to(CONFIG)}")


def replace_tags(path: Path, theme: dict):
    """Replace hex codes on lines tagged `# @concept:key[,key2,...]` (or `-- @concept:...`)."""
    tag_re = re.compile(r"[#/-]{1,2}\s*@concept:([\w,]+)\s*$")
    hex_re = re.compile(r"#[0-9a-fA-F]{6}")
    lines = path.read_text().splitlines(keepends=True)
    changed = False
    for i, line in enumerate(lines):
        m = tag_re.search(line.rstrip("\n"))
        if not m:
            continue
        keys = m.group(1).split(",")
        hexes = hex_re.findall(line)
        if len(hexes) != len(keys):
            print(f"  ! tag/hex count mismatch on {path.name}:{i+1}, skipping line")
            continue
        new_line = line
        for old, key in zip(hexes, keys):
            new_line = new_line.replace(old, "#" + theme[key], 1)
        if new_line != line:
            lines[i] = new_line
            changed = True
    if changed:
        path.write_text("".join(lines))
        print(f"  ✓ {path.relative_to(CONFIG)}")


def apply_theme(name: str):
    if name not in THEMES:
        print(f"Unknown theme '{name}'. Available: {', '.join(THEMES)}")
        sys.exit(1)
    t = THEMES[name]
    print(f"Applying theme '{name}'...")

    # hypr/colors.conf
    body = "\n".join(f"${k:<10} = rgb({v})" for k, v in [
        ("base", t["base"]), ("mantle", t["mantle"]), ("surface0", t["surface0"]),
        ("surface1", t["surface1"]), ("overlay", t["overlay"]), ("muted", t["muted"]),
        ("text", t["text"]), ("subtext", t["subtext"]),
    ]) + "\n\n" + "\n".join(f"${k:<10} = rgb({v})" for k, v in [
        ("lavender", t["lavender"]), ("rosewater", t["rosewater"]), ("red", t["red"]),
        ("green", t["green"]), ("yellow", t["yellow"]), ("peach", t["peach"]), ("cyan", t["cyan"]),
    ])
    replace_block(CONFIG / "hypr/colors.conf", body)

    # waybar/style.css
    body = "\n".join(f"@define-color {k:<9} #{v};" for k, v in t.items())
    replace_block(CONFIG / "waybar/style.css", body)

    # rofi/theme.rasi
    alpha = {"base": "f0", "mantle": "ee", "surface0": "ff", "surface1": "ff", "text": "ff", "subtext": "ff", "lavender": "ff"}
    lines = []
    for k, a in alpha.items():
        lines.append(f"    {k+':':<12}#{t[k]}{a}")
    replace_block(CONFIG / "rofi/theme.rasi", "\n".join(lines))

    # kitty/kitty.conf
    body = "\n".join([
        f"foreground              #{t['text']}",
        f"background              #{t['base']}",
        f"selection_foreground    #{t['base']}",
        f"selection_background    #{t['lavender']}",
        "",
        f"color0  #{t['mantle']}",
        f"color8  #{t['overlay']}",
        f"color1  #{t['red']}",
        f"color9  #{t['red']}",
        f"color2  #{t['green']}",
        f"color10 #{t['green']}",
        f"color3  #{t['yellow']}",
        f"color11 #{t['yellow']}",
        f"color4  #{t['lavender']}",
        f"color12 #{t['lavender']}",
        f"color5  #{t['rosewater']}",
        f"color13 #{t['rosewater']}",
        f"color6  #{t['cyan']}",
        f"color14 #{t['cyan']}",
        f"color7  #{t['text']}",
        "color15 #ffffff",
        "",
        "tab_bar_style powerline",
        f"active_tab_background   #{t['lavender']}",
        f"active_tab_foreground   #{t['mantle']}",
        f"inactive_tab_background #{t['surface0']}",
        f"inactive_tab_foreground #{t['muted']}",
    ])
    replace_block(CONFIG / "kitty/kitty.conf", body)

    # wlogout/style.css
    body = "\n".join([
        f"@define-color base       #{t['base']};",
        f"@define-color surface0   #{t['surface0']};",
        f"@define-color surface1   #{t['surface1']};",
        f"@define-color text       #{t['text']};",
        f"@define-color lavender   #{t['lavender']};",
    ])
    replace_block(CONFIG / "wlogout/style.css", body)

    # gtk-4.0/gtk.css
    body = "\n".join([
        f"@define-color accent_color #{t['lavender']};",
        f"@define-color accent_bg_color #{t['lavender']};",
        f"@define-color accent_fg_color #{t['mantle']};",
        "",
        f"@define-color window_bg_color #{t['base']};",
        f"@define-color window_fg_color #{t['text']};",
        f"@define-color view_bg_color #{t['surface0']};",
        f"@define-color view_fg_color #{t['text']};",
        f"@define-color headerbar_bg_color #{t['mantle']};",
        f"@define-color headerbar_fg_color #{t['text']};",
    ])
    replace_block(CONFIG / "gtk-4.0/gtk.css", body)

    # nvim colorscheme.lua
    body = "\n".join([
        f'            colors.bg = "#{t["base"]}"',
        f'            colors.bg_dark = "#{t["mantle"]}"',
        f'            colors.bg_float = "#{t["mantle"]}"',
        f'            colors.bg_highlight = "#{t["surface0"]}"',
        f'            colors.bg_popup = "#{t["mantle"]}"',
        f'            colors.bg_sidebar = "#{t["mantle"]}"',
        f'            colors.bg_statusline = "#{t["mantle"]}"',
        f'            colors.bg_visual = "#{t["surface1"]}"',
        f'            colors.border = "#{t["surface1"]}"',
        "",
        f'            colors.fg = "#{t["text"]}"',
        f'            colors.fg_dark = "#{t["subtext"]}"',
        f'            colors.fg_gutter = "#{t["overlay"]}"',
        f'            colors.comment = "#{t["muted"]}"',
        "",
        f'            colors.blue = "#{t["lavender"]}"',
        f'            colors.blue1 = "#{t["lavender"]}"',
        f'            colors.blue2 = "#{t["cyan"]}"',
        f'            colors.cyan = "#{t["cyan"]}"',
        f'            colors.purple = "#{t["lavender"]}"',
        f'            colors.magenta = "#{t["rosewater"]}"',
        f'            colors.magenta2 = "#{t["rosewater"]}"',
        f'            colors.red = "#{t["red"]}"',
        f'            colors.red1 = "#{t["red"]}"',
        f'            colors.orange = "#{t["peach"]}"',
        f'            colors.yellow = "#{t["yellow"]}"',
        f'            colors.green = "#{t["green"]}"',
        f'            colors.green1 = "#{t["green"]}"',
        f'            colors.teal = "#{t["cyan"]}"',
        "",
        f'            colors.terminal_black = "#{t["surface0"]}"',
    ])
    replace_block(CONFIG / "nvim/lua/plugins/colorscheme.lua", body, begin="-- BEGIN CONCEPT-THEME", end="-- END CONCEPT-THEME")

    # starship.toml — format block + tagged lines
    body = (
        'format = """\n'
        f'[](fg:#{t["lavender"]})[  $directory]($style_dir)[](bg:#{t["surface0"]} fg:#{t["lavender"]})'
        f'$git_branch$git_status[](fg:#{t["surface0"]})\n'
        '$character"""'
    )
    replace_block(CONFIG / "starship.toml", body, begin="# BEGIN CONCEPT-THEME-FORMAT", end="# END CONCEPT-THEME-FORMAT")
    replace_tags(CONFIG / "starship.toml", t)

    # dunstrc — tagged lines only
    replace_tags(CONFIG / "dunst/dunstrc", t)

    # fastfetch — tagged lines only
    replace_tags(CONFIG / "fastfetch/config.jsonc", t)

    # remember current theme for the concept-panel UI
    (CONFIG / "hypr/.current-theme").write_text(name + "\n")

    # ── reload what can be reloaded live ──
    print("Reloading...")

    def safe_run(cmd):
        try:
            subprocess.run(cmd, check=False)
        except FileNotFoundError:
            pass

    safe_run(["hyprctl", "reload"])
    safe_run(["pkill", "-SIGUSR2", "waybar"])
    safe_run(["pkill", "-SIGUSR2", "dunst"])
    print(
        "Done. Note: kitty (open windows), rofi, wlogout, starship and nvim\n"
        "pick up the new theme the next time they're opened/started — they\n"
        "don't repaint live."
    )


if __name__ == "__main__":
    if len(sys.argv) != 2 or sys.argv[1] in ("-h", "--help"):
        print(__doc__)
        sys.exit(0)
    if sys.argv[1] == "--list":
        print("\n".join(THEMES))
        sys.exit(0)
    apply_theme(sys.argv[1])
