# Environment Variables

# Editor
set -gx EDITOR micro
set -gx VISUAL $EDITOR

# Pager
set -gx PAGER less
set -gx LESS '-R --use-color -Dd+r$Du+b'
# MANPAGER is set in the man function to handle bat/less conditionally

# Terminal
set -gx TERM xterm-256color

# Locale
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# XDG Base Directory
set -gx XDG_CONFIG_HOME ~/.config
set -gx XDG_DATA_HOME ~/.local/share
set -gx XDG_STATE_HOME ~/.local/state
set -gx XDG_CACHE_HOME ~/.cache

# Development
set -gx CARGO_HOME ~/.cargo
set -gx RUSTUP_HOME ~/.rustup
set -gx GOPATH ~/.go
set -gx NPM_CONFIG_PREFIX ~/.npm-global

# FZF Theme (matching your color scheme)
set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7 --color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a'

# Bat theme
set -gx BAT_THEME "TwoDark"