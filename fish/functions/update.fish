function update --description 'Update all package managers'
    echo "=== System Packages ==="
    if type -q pacman
        sudo pacman -Syu
    else if type -q apt
        sudo apt update && sudo apt upgrade
    else if type -q dnf
        sudo dnf upgrade
    else if type -q zypper
        sudo zypper update
    end
    
    echo -e "\n=== Fisher Plugins ==="
    if functions -q fisher
        fisher update
    end
    
    echo -e "\n=== Flatpak ==="
    if type -q flatpak
        flatpak update -y
    end
    
    echo -e "\n=== Snap ==="
    if type -q snap
        sudo snap refresh
    end
    
    echo -e "\n=== Rust ==="
    if type -q rustup
        rustup update
    end
    
    echo -e "\n=== Cargo packages ==="
    if type -q cargo-install-update
        cargo install-update -a
    else if type -q cargo
        echo "Install cargo-update: cargo install cargo-update"
    end
    
    echo -e "\n=== NPM packages ==="
    if type -q npm
        npm update -g
    end
    
    echo -e "\n=== Python packages ==="
    if type -q pip
        pip list --outdated --format=json | python -c "import json, sys; print('\n'.join([x['name'] for x in json.load(sys.stdin)]))" | xargs -n1 pip install -U 2>/dev/null
    end
    
    if type -q pipx
        pipx upgrade-all
    end
    
    if type -q uv
        uv self update
    end
    
    echo -e "\n=== Go packages ==="
    if type -q go
        go get -u all
    end
    
    echo -e "\nAll updates completed!"
end