# PATH configuration

# User binaries
fish_add_path -g ~/.local/bin
fish_add_path -g ~/.npm-global/bin
fish_add_path -g ~/.cargo/bin
fish_add_path -g ~/.go/bin

# Python
# Add pipx paths if directory exists
if test -d ~/.local/pipx/venvs
    for dir in ~/.local/pipx/venvs/*/bin
        if test -d $dir
            fish_add_path -g $dir
        end
    end
end
fish_add_path -g ~/.pyenv/bin

# Development tools
fish_add_path -g /usr/local/go/bin
fish_add_path -g ~/.deno/bin
fish_add_path -g ~/.bun/bin

# System
fish_add_path -g /usr/local/sbin
fish_add_path -g /usr/sbin
fish_add_path -g /sbin
