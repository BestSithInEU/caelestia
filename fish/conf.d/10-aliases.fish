# General Aliases

# Navigation
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
# Note: ~ and - cannot be used as alias names in fish
# Use functions instead or just use the commands directly

# Core utilities replacements
alias ls 'eza --icons --group-directories-first'
alias lt 'eza --tree --icons --level=2'
alias lta 'eza --tree --icons --level=2 -la'

alias cat 'bat --paging=never'
alias less 'bat'
alias find 'fd'
alias ps 'procs'
alias top 'btop'
alias htop 'btop'
alias df 'duf'
alias du 'dust'
alias dig 'dog'

# File operations
alias cp 'cp -iv'
alias mv 'mv -iv'
alias rm 'rm -Iv'
alias mkdir 'mkdir -pv'
alias rmdir 'rmdir -v'

# System
alias reboot 'sudo systemctl reboot'
alias poweroff 'sudo systemctl poweroff'
alias suspend 'systemctl suspend'
alias hibernate 'systemctl hibernate'

# Shortcuts
alias e '$EDITOR'
alias v 'nvim'
alias c 'clear'
alias q 'exit'
alias h 'history'
alias j 'jobs -l'
alias which 'type -a'
alias showpath 'printf "%s\n" $PATH | nl'

# Network
alias ip 'ip -color=auto'
alias ports 'ss -tulanp'
alias listening 'ss -tulnp'
alias myip 'command curl -s https://ipinfo.io/ip'
alias speedtest 'command curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'

# Package management (paru) — functions instead of aliases to avoid inheriting paru completions
function install --description 'Install packages'; paru -S $argv; end
function search --description 'Search packages'; paru -Ss $argv; end
function remove --description 'Remove packages'; paru -Rns $argv; end
function cleanup --description 'Clean package cache'; paru -Sc $argv; end
function orphans --description 'Remove orphaned packages'; paru -Qdtq | paru -Rns -; end
function pkginfo --description 'Show package info'; paru -Qi $argv; end
function pkglist --description 'List installed packages'; paru -Qe $argv; end

# Safety nets
alias chown 'chown --preserve-root'
alias chmod 'chmod --preserve-root'
alias chgrp 'chgrp --preserve-root'

# Verbose operations
alias wget 'wget -c'
alias curl 'curl -w "\n"'
alias dd 'dd status=progress'

# Clipboard
alias pbcopy 'wl-copy'
alias pbpaste 'wl-paste'
