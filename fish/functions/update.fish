function update --description 'Update all package managers'
    echo "=== System Packages ==="
    if type -q paru
        paru -Syu
    else if type -q pacman
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
    if type -q uv
        uv self update
        uv tool upgrade --all 2>/dev/null
    end

    if type -q pipx
        pipx upgrade-all
    end

    echo -e "\nAll updates completed!"
end
