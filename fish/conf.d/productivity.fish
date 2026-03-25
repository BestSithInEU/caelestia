# Quick calculations
function calc
    if test (count $argv) -eq 0
        echo "Usage: calc <expression>"
        return 1
    end
    echo "scale=4; $argv" | bc -l
end

# System monitoring
function sysinfo
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo ""
    echo "=== CPU ==="
    lscpu | grep "Model name" | sed 's/Model name:/CPU:/'
    echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo ""
    echo "=== Memory ==="
    free -h | grep "^Mem"
    echo ""
    echo "=== Disk Usage ==="
    command df -h / | tail -1
    echo ""
    echo "=== Network ==="
    command ip -4 addr show | grep inet | grep -v 127.0.0.1 | awk '{print $2}'
end

# Weather
function weather
    set -l location $argv[1]
    if test -z "$location"
        set location "auto"
    end
    command curl -s "wttr.in/$location?format=v2"
end

# Cheatsheet
function cheat
    if test (count $argv) -eq 0
        echo "Usage: cheat <command>"
        return 1
    end
    command curl -s "cheat.sh/$argv[1]"
end

# Timer and stopwatch
function timer
    if test (count $argv) -eq 0
        echo "Usage: timer <seconds>"
        return 1
    end

    set -l duration $argv[1]
    echo "Timer set for $duration seconds"
    sleep $duration
    echo -e "\a"
    notify-send "Timer" "Time's up! ($duration seconds)" 2>/dev/null || echo "Time's up!"
end

function stopwatch
    set -l start_time (date +%s)
    echo "Stopwatch started. Press Ctrl+C to stop."

    while true
        set -l current_time (date +%s)
        set -l elapsed (math $current_time - $start_time)
        set -l hours (math floor $elapsed / 3600)
        set -l minutes (math floor "($elapsed % 3600) / 60")
        set -l seconds (math $elapsed % 60)
        printf "\r%02d:%02d:%02d" $hours $minutes $seconds
        sleep 1
    end
end

# File backup
function backup
    if test (count $argv) -eq 0
        echo "Usage: backup <file_or_directory>"
        return 1
    end

    set -l source $argv[1]
    set -l backup_name "$source.backup."(date +%Y%m%d_%H%M%S)

    if test -e $source
        command cp -r $source $backup_name
        echo "Backed up to $backup_name"
    else
        echo "Source not found: $source"
    end
end

# Quick SSH key generation
function sshkeygen
    set -l key_name $argv[1]
    if test -z "$key_name"
        set key_name "id_ed25519"
    end

    ssh-keygen -t ed25519 -f ~/.ssh/$key_name -C (whoami)@(hostname)
    echo "SSH key generated: ~/.ssh/$key_name"
end

# Port checker
function port
    if test (count $argv) -eq 0
        echo "Usage: port <port_number>"
        return 1
    end

    sudo lsof -i :$argv[1] || echo "Port $argv[1] is not in use"
end

# Process finder
function pf
    if test (count $argv) -eq 0
        echo "Usage: pf <process_name>"
        return 1
    end

    command ps aux | grep -i $argv[1] | grep -v grep
end

# Kill process by name
function pk
    if test (count $argv) -eq 0
        echo "Usage: pk <process_name>"
        return 1
    end

    set -l pids (command ps aux | grep -i $argv[1] | grep -v grep | awk '{print $2}')
    if test -n "$pids"
        echo "Killing processes: $pids"
        echo $pids | xargs kill -9
    else
        echo "No processes found matching: $argv[1]"
    end
end

# Find large files
function findlarge
    set -l size "100M"
    set -l dir "."

    if test (count $argv) -ge 1
        set size $argv[1]
    end
    if test (count $argv) -ge 2
        set dir $argv[2]
    end

    command find $dir -type f -size +$size -exec ls -lh {} \; | awk '{print $5 " " $9}'
end

# Quick project templates
function project
    if test (count $argv) -eq 0
        echo "Usage: project <type> <name>"
        echo "Types: python, node, rust, go, cpp, web"
        return 1
    end

    set -l type $argv[1]
    set -l name $argv[2]

    if test -z "$name"
        echo "Please provide a project name"
        return 1
    end

    switch $type
        case python
            mkdir -p $name/{src,tests,docs}
            echo "# $name" > $name/README.md
            echo "# Python project" > $name/pyproject.toml
            echo ".venv/\n__pycache__/\n*.pyc\n.pytest_cache/" > $name/.gitignore
            echo "Python project created: $name"

        case node
            mkdir -p $name/{src,tests,public}
            echo "# $name" > $name/README.md
            echo '{"name": "'$name'", "version": "1.0.0"}' > $name/package.json
            echo "node_modules/\ndist/\n.env" > $name/.gitignore
            echo "Node project created: $name"

        case rust
            cargo new $name
            echo "Rust project created: $name"

        case go
            mkdir -p $name/{cmd,internal,pkg}
            echo "module $name" > $name/go.mod
            echo "package main\n\nfunc main() {\n\t\n}" > $name/cmd/main.go
            echo "Go project created: $name"

        case cpp
            cpp-new $name

        case web
            mkdir -p $name/{css,js,images}
            echo "<!DOCTYPE html>\n<html>\n<head>\n\t<title>$name</title>\n\t<link rel=\"stylesheet\" href=\"css/style.css\">\n</head>\n<body>\n\t<h1>$name</h1>\n\t<script src=\"js/script.js\"></script>\n</body>\n</html>" > $name/index.html
            touch $name/css/style.css $name/js/script.js
            echo "Web project created: $name"

        case '*'
            echo "Unknown project type: $type"
    end
end

# URL shortener using is.gd
function shorten
    if test (count $argv) -eq 0
        echo "Usage: shorten <url>"
        return 1
    end
    command curl -s "https://is.gd/create.php?format=simple&url=$argv[1]"
end

# Color palette
function colors
    for i in (seq 0 15)
        printf "\033[48;5;%sm %3s \033[0m" $i $i
        if test (math "$i % 8") -eq 7
            printf "\n"
        end
    end

    for i in (seq 16 231)
        printf "\033[48;5;%sm %3s \033[0m" $i $i
        if test (math "($i - 16) % 12") -eq 11
            printf "\n"
        end
    end

    for i in (seq 232 255)
        printf "\033[48;5;%sm %3s \033[0m" $i $i
        if test (math "($i - 232) % 12") -eq 11
            printf "\n"
        end
    end
end

# Quick aliases for common directories
alias desk 'cd ~/Desktop'
alias docs 'cd ~/Documents'
alias dl 'cd ~/Downloads'
alias pics 'cd ~/Pictures'
alias vids 'cd ~/Videos'
alias music 'cd ~/Music'
alias proj 'cd ~/Documents/Projects'
alias dots 'cd ~/Documents/Projects/caelestia'

# System maintenance
function sys-clean --description 'Clean system caches and logs'
    echo "=== Paru cache ==="
    paru -Sc --noconfirm
    echo -e "\n=== Orphaned packages ==="
    set -l orphans (paru -Qdtq)
    if test -n "$orphans"
        echo $orphans
        echo "Run 'orphans' to remove them"
    else
        echo "None found"
    end
    echo -e "\n=== Journal ==="
    sudo journalctl --vacuum-time=7d
    echo -e "\n=== Home cache ==="
    echo "Cache size: "(command du -sh ~/.cache 2>/dev/null | cut -f1)
end

function journal-clean --description 'Clean old journal entries'
    sudo journalctl --vacuum-time=$argv[1] 2>/dev/null
    or sudo journalctl --vacuum-time=7d
end

function please --description 'Re-run last command with sudo'
    command sudo $history[1]
end

function reload --description 'Reload fish config'
    exec fish
end

# Quick throwaway workspace
function tmp --description 'Create and cd into temp directory'
    set -l dir (mktemp -d)
    cd $dir
    echo "Working in $dir"
end

# Quick config editing
function conf --description 'Edit common config files'
    switch $argv[1]
        case fish
            $EDITOR ~/.config/fish/config.fish
        case hypr
            $EDITOR ~/.config/hypr/hyprland.conf
        case star starship
            $EDITOR ~/.config/starship.toml
        case ''
            echo "Usage: conf <fish|hypr|starship>"
    end
end

# Generate random password
function genpass --description 'Generate random password'
    set -l len $argv[1]
    test -z "$len"; and set len 24
    head -c 256 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9!@#$%' | head -c $len
    echo
end

# Base64 encode/decode
function encode --description 'Base64 encode'
    echo -n $argv | base64
end

function decode --description 'Base64 decode'
    echo -n $argv | base64 -d
    echo
end
