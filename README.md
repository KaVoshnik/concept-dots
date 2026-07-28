<div align="center">

# concept-dots

**A minimal, muted-tone Hyprland setup for CachyOS**

_fish · waybar · rofi · kitty · hyprlock_

![hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=for-the-badge&logo=wayland&logoColor=black)
![cachyos](https://img.shields.io/badge/CachyOS-0B0C0F?style=for-the-badge&logo=archlinux&logoColor=white)
![license](https://img.shields.io/badge/license-MIT-8aa6f7?style=for-the-badge)

</div>

---

## Preview

![screenshot](assets/screenshot-01.png)

## What's inside

| Component      | Tool                                   |
| -------------- | -------------------------------------- |
| Compositor     | [Hyprland](https://hyprland.org)       |
| Bar            | Waybar                                 |
| Launcher       | Rofi (wayland fork)                    |
| Terminal       | Kitty                                  |
| Shell          | fish + starship prompt                 |
| Editor         | Neovim (lazy.nvim, LSP, treesitter)    |
| Code editor    | VS Code (`visual-studio-code-bin`)     |
| Browser        | [Zen Browser](https://zen-browser.app) |
| Lockscreen     | hyprlock + hypridle                    |
| Notifications  | dunst                                  |
| Logout menu    | wlogout                                |
| Wallpaper      | swww (live-switchable)                 |
| Settings panel | Quickshell (`concept-panel`)           |
| Fetch splash   | fastfetch                              |
| GTK theming    | adw-gtk3-dark + nwg-look               |
| Qt theming     | qt5ct/qt6ct + Kvantum                  |

Color palette is a custom low-saturation dark theme called **concept** — muted lavender/rosewater accents on a near-black base, kept consistent across every app (see `.config/hypr/colors.conf`).

## Requirements

- A fresh **CachyOS** (or any Arch-based distro) install
- An internet connection (the installer builds `paru` if it's missing)
- Not running as root

## Install

```bash
git clone https://github.com/kavoshnik/concept-dots.git
cd concept-dots
./install.sh
```

The script will:

1. Install `paru` (AUR helper) if it isn't already present
2. Install all required packages via `pacman` + `paru`
3. Back up your existing `~/.config` entries to `~/.config-backup-<timestamp>`
4. Symlink this repo's configs into `~/.config`
5. Install Fisher + fish plugins
6. Offer to set `fish` as your default shell

After it finishes: **reboot or re-login**, then pick Hyprland at your display/login manager.

## Post-install

- Edit `~/.config/hypr/monitors.conf` for your actual monitor layout (`hyprctl monitors` to check names)
- Drop a wallpaper at `~/.config/hypr/wallpapers/default.png`
- Keybinds live in `~/.config/hypr/keybinds.conf` — default mod key is `SUPER`

### Key defaults

| Keys                | Action                                          |
| ------------------- | ----------------------------------------------- |
| `SUPER + T`         | Terminal (kitty)                                |
| `SUPER + A`         | App launcher (rofi)                             |
| `SUPER + Q`         | Close window                                    |
| `SUPER + E`         | File manager                                    |
| `SUPER + B`         | Browser (Zen)                                   |
| `SUPER + S`         | Toggle concept-panel (wallpaper/theme switcher) |
| `SUPER + L`         | Lock screen                                     |
| `SUPER + ESC`       | Logout menu                                     |
| `SUPER + SHIFT + S` | Screenshot (region)                             |
| `SUPER + SHIFT + V` | Clipboard history                               |
| `SUPER + 1-0`       | Switch workspace                                |

## Optional extras

`install.sh` will ask at the end whether you want these — both can also be run standalone any time:

```bash
./scripts/install-sddm-theme.sh silvia   # SilentSDDM login theme, "silvia" preset
./scripts/install-grub-theme.sh          # Elegant GRUB2 bootloader theme
```

- **[SilentSDDM](https://github.com/uiriansan/SilentSDDM)** — a polished SDDM login theme. Other bundled presets: `default`, `rei`, `ken`, `everforest`, `catppuccin-latte/frappe/macchiato/mocha`, `nord`.
- **[Elegant-grub2-themes](https://github.com/vinceliuice/Elegant-grub2-themes)** — a GRUB bootloader theme. Skipped automatically if your system doesn't use GRUB (e.g. systemd-boot). Default install is `forest / window / left / light / 1080p` — edit the flags inside the script for other variants.

## concept-panel — wallpaper & theme switcher

Press **`SUPER + S`** to open a small [Quickshell](https://quickshell.org) panel with two tabs:

- **Wallpaper** — a grid of everything in `.config/hypr/wallpapers/`. Click one to apply it live via `swww` (with a wipe transition). The choice is remembered as `wallpapers/current.png`, which `hyprlock` and `fastfetch` also read — so your lockscreen and terminal splash always match the desktop.
- **Theme** — pick between the built-in `concept` (default, matches the wallpaper) and `aurora` (warm amber/mint alt) palettes. Clicking one runs `scripts/apply-theme.py`, which regenerates the color blocks in _every_ themed config (Hyprland, Waybar, Rofi, Kitty, wlogout, GTK, Neovim, Starship, dunst, fastfetch) from one palette definition and reloads what can reload live (Hyprland, Waybar, dunst). Things that can't repaint live (open Kitty windows, Rofi, Neovim, GTK apps) pick up the new theme the next time they're started.

**Adding your own wallpaper:** just drop an image into `.config/hypr/wallpapers/` — it shows up in the grid automatically, no config needed.

**Adding your own theme:** add an entry to the `THEMES` dict at the top of `scripts/apply-theme.py` (14 hex values), then add a matching card to the theme grid in `.config/quickshell/concept-panel/shell.qml`. Every themed file already knows how to regenerate itself from any palette that has those 14 keys.

You can also apply a theme without the GUI:

```bash
~/.config/concept-dots/scripts/apply-theme.py aurora
~/.config/concept-dots/scripts/apply-theme.py concept
~/.config/concept-dots/scripts/apply-theme.py --list
```

## Neovim

A from-scratch [lazy.nvim](https://github.com/folke/lazy.nvim) setup — not a LazyVim/NvChad wrapper — so you can see exactly what's installed and why:

- **LSP** via mason.nvim + nvim-lspconfig (lua, python, TS/JS, bash, rust preconfigured — add more in `lua/plugins/coding.lua`)
- **Completion** via nvim-cmp + LuaSnip
- **Treesitter** for syntax highlighting/indent
- **Telescope** for fuzzy finding (`<leader>ff`/`<leader>fg`/`<leader>fb`)
- **nvim-tree** file explorer (`<leader>e`)
- **gitsigns**, **which-key**, **Comment.nvim**, **flash.nvim**, **noice.nvim**
- Colorscheme: tokyonight, retinted to the `concept` palette

First launch will bootstrap lazy.nvim and install plugins automatically — give it a minute.

## GTK & Qt theming

So Firefox, GTK apps, and Qt apps (e.g. `qbittorrent`, `dolphin`) don't visually clash with the rest of the setup:

- **GTK** — `adw-gtk3-dark` (a libadwaita-faithful GTK3 theme) + Papirus-Dark icons + Bibata cursors, wired via `.config/gtk-3.0` / `.config/gtk-4.0`. Fine-tune further with `nwg-look`.
- **Qt** — `qt5ct`/`qt6ct` set the platform theme, actual rendering is handled by **Kvantum** (`KvantumDark` base). Run `kvantummanager` if you want to hand-tune the accent color further.

## Wallpaper & palette

The `concept` palette was tuned to match `.config/hypr/wallpapers/default.png` — extracted straight from the wallpaper's pixels (lavender-blue `#8a90f0`, rose-magenta `#e8a0c8`, cyan `#35a8b4`, near-black/near-white base). `wallpapers/current.png` is a symlink to whichever wallpaper is active — switch it from the [concept-panel](#-concept-panel--wallpaper--theme-switcher) (`SUPER+S`) rather than editing it by hand. If you swap in your own wallpaper with very different colors, re-tune (or add) a matching palette in `scripts/apply-theme.py` for the same cohesive look.

`fastfetch` and `hyprlock` both read `current.png` too — so the login splash, the lockscreen, and the desktop always match.

## Troubleshooting

If `SUPER+S` does nothing: check `qs -c concept-panel` runs without errors in a terminal first. Quickshell's QML API has moved around between versions — if `shell.qml` throws on your version, try the `quickshell-git` AUR package instead of `quickshell`, or check [quickshell.org/docs](https://quickshell.org) for the current `PanelWindow`/`FloatingWindow`/`IpcHandler` syntax; the logic (list files, run a script on click) doesn't change, only the exact API shapes might.

CachyOS is rolling-release, and Hyprland breaks its own config syntax fairly often (window rules were fully rewritten in 0.53, `hyprpaper` switched to a block-based config in 0.8.0 — this repo has since moved to `swww` instead, dispatchers like `togglesplit`/`swapsplit` were later removed in favor of `layoutmsg`). If you see `Config error in file ...` on screen after a system update:

1. Check your installed version: `hyprctl version`
2. Check the [Hyprland changelog](https://hypr.land/news/) / [wiki](https://wiki.hypr.land/) for the version you're on — breaking changes are usually called out explicitly
3. Compare against this repo's configs; syntax drift is the most common cause, not a real misconfiguration

## Structure

```
concept-dots/
├── install.sh
├── .config/
│   ├── hypr/           # hyprland.conf, keybinds, rules, colors, lock/idle
│   ├── waybar/          # config.jsonc + style.css
│   ├── rofi/            # config.rasi + theme.rasi
│   ├── kitty/
│   ├── fish/             # config.fish + functions/ + fish_plugins
│   ├── starship.toml
│   ├── dunst/
│   ├── wlogout/
│   ├── fastfetch/
│   ├── nvim/               # lazy.nvim, LSP, treesitter, telescope...
│   ├── gtk-3.0/ gtk-4.0/
│   ├── qt5ct/ qt6ct/
│   ├── Kvantum/
│   └── quickshell/
│       └── concept-panel/  # wallpaper & theme switcher (SUPER+S)
├── scripts/
│   ├── apply-theme.py      # regenerates colors across every config
│   ├── apply-wallpaper.sh  # live wallpaper switch via swww
│   ├── install-sddm-theme.sh
│   └── install-grub-theme.sh
├── wallpapers/
└── assets/               # screenshots for this README
```

## Customizing the palette

Palettes are defined once, in `scripts/apply-theme.py` (`THEMES` dict), and every themed file gets regenerated from there — see [concept-panel](#-concept-panel--wallpaper--theme-switcher) above. Files carry `BEGIN CONCEPT-THEME` / `END CONCEPT-THEME` markers (or `# @concept:key` line tags where the format doesn't support blocks — dunst, starship, fastfetch) showing exactly what gets rewritten. Editing colors by hand inside those markers works fine until the next theme switch overwrites them — for a permanent change, edit the palette in `apply-theme.py` instead.

## License

MIT — do whatever you want with it.
