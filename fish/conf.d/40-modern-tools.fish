# Modern CLI Tools Configuration

# Zoxide - smarter cd
if type -q zoxide
    zoxide init fish | source
    alias cd __zoxide_z
    alias cdi __zoxide_zi
end

# Eza configuration (modern ls)
set -gx EZA_ICONS_AUTO true
set -gx EZA_COLORS "uu=36:gu=37:sn=32:sb=32:da=34:ur=34:uw=35:ux=36:ue=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36"

# fd configuration
set -gx FD_OPTIONS "--hidden --follow --exclude .git --exclude node_modules --exclude .cache"

# Ripgrep configuration - use symlinked config
set -l config_dir (dirname (status filename))/../..
if test -f "$config_dir/ripgrep/config"
    set -gx RIPGREP_CONFIG_PATH "$config_dir/ripgrep/config"
else if test -f ~/.config/ripgrep/config
    set -gx RIPGREP_CONFIG_PATH ~/.config/ripgrep/config
end

# Bat configuration
set -gx BAT_STYLE "numbers,changes,header"

# Advanced eza aliases
alias e1 'eza -1'
alias ea 'eza -a'
alias ee 'eza -lah --git'
alias et 'eza -T'
alias eta 'eza -Ta'
alias etl 'eza -Tl'
alias etla 'eza -Tla'
alias etc 'eza -T --color=always | head -20'
alias etd 'eza -TD'
alias etg 'eza -Tl --git --git-ignore'

# fd aliases
alias fdf 'fd -t f'
alias fdd 'fd -t d'
alias fdh 'fd -H'
alias fdi 'fd -I'
alias fde 'fd -e'
alias fdx 'fd -t x'

# ripgrep aliases
alias rgi 'rg -i'
alias rgf 'rg --files'
alias rgh 'rg --hidden'
alias rgn 'rg --no-ignore'
alias rgc 'rg --count'
alias rgl 'rg -l'
alias rgp 'rg --pretty'

# tokei for code statistics
alias loc 'tokei'
alias locl 'tokei --languages'
alias loct 'tokei --type'
alias locs 'tokei --sort code'

# Modern replacements functions
function up
    set -l count $argv[1]
    if test -z "$count"
        set count 1
    end
    set -l path ""
    for i in (seq $count)
        set path "../$path"
    end
    cd $path
end

function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end

function extract
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2'
                tar xjf $argv[1]
            case '*.tar.gz'
                tar xzf $argv[1]
            case '*.tar.xz'
                tar xJf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.tbz2'
                tar xjf $argv[1]
            case '*.tgz'
                tar xzf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.Z'
                uncompress $argv[1]
            case '*.7z'
                7z x $argv[1]
            case '*.rar'
                unrar x $argv[1]
            case '*'
                echo "Unknown archive format"
        end
    else
        echo "$argv[1] is not a valid file"
    end
end

# Quick file/directory size
function sizeof
    if test -z "$argv"
        dust -d 1
    else
        dust $argv
    end
end

# Interactive file manager with preview
function fm
    if type -q ranger
        ranger $argv
    else if type -q lf
        lf $argv
    else if type -q nnn
        nnn -deH $argv
    else
        echo "No file manager found (ranger/lf/nnn)"
    end
end

# Quick HTTP server
function serve
    set -l port 8000
    if test -n "$argv[1]"
        set port $argv[1]
    end
    python3 -m http.server $port
end

# JSON tools
function json
    if test -p /dev/stdin
        cat | jq '.'
    else if test -f "$argv[1]"
        jq '.' $argv[1]
    else
        echo "$argv" | jq '.'
    end
end

function json-pretty
    if test -p /dev/stdin
        cat | jq '.' > /tmp/json_pretty.json && mv /tmp/json_pretty.json $argv[1]
    else
        jq '.' $argv[1] > /tmp/json_pretty.json && mv /tmp/json_pretty.json $argv[1]
    end
end