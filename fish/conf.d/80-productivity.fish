# Productivity Functions and Utilities

# Quick directory navigation and bookmarking
function mark
    if test (count $argv) -eq 0
        echo "Usage: mark <bookmark_name>"
        return 1
    end
    echo "set -gx MARK_$argv[1] $PWD" >> ~/.config/fish/conf.d/99-bookmarks.fish
    echo "Bookmarked $PWD as $argv[1]"
end

function jump
    if test (count $argv) -eq 0
        echo "Available bookmarks:"
        set | grep "^MARK_" | sed 's/MARK_/  /' | sed 's/=/ -> /'
        return 0
    end
    
    set -l bookmark MARK_$argv[1]
    if set -q $bookmark
        cd (eval echo \$$bookmark)
    else
        echo "Bookmark '$argv[1]' not found"
    end
end

function unmark
    if test (count $argv) -eq 0
        echo "Usage: unmark <bookmark_name>"
        return 1
    end
    set -e MARK_$argv[1]
    sed -i "/MARK_$argv[1]/d" ~/.config/fish/conf.d/99-bookmarks.fish
    echo "Removed bookmark $argv[1]"
end

# Quick notes
function note
    set -l notes_dir ~/.local/share/notes
    mkdir -p $notes_dir
    
    if test (count $argv) -eq 0
        $EDITOR $notes_dir/(date +%Y-%m-%d).md
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S'): $argv" >> $notes_dir/(date +%Y-%m-%d).md
        echo "Note added"
    end
end

function notes
    set -l notes_dir ~/.local/share/notes
    if test -d $notes_dir
        eza -la --icons $notes_dir
    else
        echo "No notes directory found"
    end
end

function todo
    set -l todo_file ~/.local/share/todo.md
    
    if test (count $argv) -eq 0
        if test -f $todo_file
            bat $todo_file
        else
            echo "No todos found"
        end
    else if test "$argv[1]" = "add"
        echo "- [ ] $argv[2..-1]" >> $todo_file
        echo "Todo added"
    else if test "$argv[1]" = "edit"
        $EDITOR $todo_file
    else if test "$argv[1]" = "clear"
        rm -f $todo_file
        echo "Todos cleared"
    else
        echo "Usage: todo [add <task>|edit|clear]"
    end
end

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
    df -h / | tail -1
    echo ""
    echo "=== Network ==="
    ip -4 addr show | grep inet | grep -v 127.0.0.1 | awk '{print $2}'
end

# Weather
function weather
    set -l location $argv[1]
    if test -z "$location"
        set location "auto"
    end
    curl -s "wttr.in/$location?format=v2"
end

# Cheatsheet
function cheat
    if test (count $argv) -eq 0
        echo "Usage: cheat <command>"
        return 1
    end
    curl -s "cheat.sh/$argv[1]"
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
        cp -r $source $backup_name
        echo "Backed up to $backup_name"
    else
        echo "Source not found: $source"
    end
end

# Archive extraction helper (enhanced)
function unpack
    if test (count $argv) -eq 0
        echo "Usage: unpack <archive>"
        return 1
    end
    
    for file in $argv
        if test -f $file
            echo "Extracting $file..."
            extract $file
        else
            echo "File not found: $file"
        end
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
    
    ps aux | grep -i $argv[1] | grep -v grep
end

# Kill process by name
function pk
    if test (count $argv) -eq 0
        echo "Usage: pk <process_name>"
        return 1
    end
    
    set -l pids (ps aux | grep -i $argv[1] | grep -v grep | awk '{print $2}')
    if test -n "$pids"
        echo "Killing processes: $pids"
        echo $pids | xargs kill -9
    else
        echo "No processes found matching: $argv[1]"
    end
end

# Directory size summary
function dirsize
    set -l dir $argv[1]
    if test -z "$dir"
        set dir "."
    end
    
    du -h --max-depth=1 $dir | sort -hr
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
    
    find $dir -type f -size +$size -exec ls -lh {} \; | awk '{print $5 " " $9}'
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
    curl -s "https://is.gd/create.php?format=simple&url=$argv[1]"
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

# Man page with color - use bat if available, otherwise colored less
function man --wraps man --description 'Colorized man pages'
    if type -q bat
        set -lx MANPAGER "sh -c 'col -bx | bat -l man -p'"
        command man $argv
    else
        set -lx LESS_TERMCAP_mb \e'[1;31m'
        set -lx LESS_TERMCAP_md \e'[1;31m'
        set -lx LESS_TERMCAP_me \e'[0m'
        set -lx LESS_TERMCAP_se \e'[0m'
        set -lx LESS_TERMCAP_so \e'[1;44;33m'
        set -lx LESS_TERMCAP_ue \e'[0m'
        set -lx LESS_TERMCAP_us \e'[1;32m'
        command man $argv
    end
end

# Quick aliases for common directories
alias desk 'cd ~/Desktop'
alias docs 'cd ~/Documents'
alias dl 'cd ~/Downloads'
alias pics 'cd ~/Pictures'
alias vids 'cd ~/Videos'
alias music 'cd ~/Music'
alias proj 'cd ~/Projects'
alias conf 'cd ~/.config'
alias dots 'cd ~/dotfiles'