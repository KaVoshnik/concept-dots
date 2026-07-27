# ─────────────────────────────────────
#  fish config — part of "concept" dotfiles
# ─────────────────────────────────────

if status is-interactive
    # remove default fish greeting
    set fish_greeting

    # ── prompt ──
    starship init fish | source

    # ── fastfetch splash on new terminal ──
    if type -q fastfetch
        fastfetch
    end

    # ── history / behavior ──
    set -g fish_autosuggestion_enabled 1

    # ── colors (matches concept palette) ──
    set -g fish_color_normal        e8e8ec
    set -g fish_color_command       8a90f0
    set -g fish_color_param         a3a3b0
    set -g fish_color_keyword       e8a0c8
    set -g fish_color_quote         e8c48a
    set -g fish_color_redirection   e8e8ec
    set -g fish_color_end           8a90f0
    set -g fish_color_error         f0645c
    set -g fish_color_comment       72758c
    set -g fish_color_autosuggestion 47475c
    set -g fish_color_cwd           7cbd82
end

# ── PATH ──
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin

# ── env ──
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx BROWSER firefox
set -gx TERM xterm-256color

# ── aliases (aka "the zshrc habits") ──
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias cat='bat --style=plain'
alias grep='rg'
alias cd='z'                      # zoxide
alias vim='nvim'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias update='sudo pacman -Syu && paru -Sua'
alias cleanup='sudo pacman -Sc && paru -Sc'

# ── tools ──
zoxide init fish | source
