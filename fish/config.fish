if status is-interactive
    # Fisher Package Manager - Auto-install, check, and update
    set -l config_dir (dirname (status filename))

    if not functions -q fisher
        echo "📦 Installing Fisher package manager..."

        # Create functions directory if it doesn't exist
        mkdir -p ~/.config/fish/functions

        # Try to get Fisher from the web, fallback to manual installation
        if command -v curl >/dev/null 2>&1
            if curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish -o ~/.config/fish/functions/fisher.fish 2>/dev/null
                echo "✅ Fisher downloaded successfully"
            else
                echo "❌ Failed to download Fisher from web, please check internet connection"
                return
            end
        else
            echo "❌ curl not found, cannot download Fisher"
            return
        end

        # Source the new fisher function
        source ~/.config/fish/functions/fisher.fish

        # Install Fisher itself first
        fisher install jorgebucaran/fisher 2>/dev/null

        # Install plugins from fish_plugins file
        if test -f "$config_dir/fish_plugins"
            echo "📦 Installing plugins from fish_plugins..."

            set -l plugins (cat "$config_dir/fish_plugins" | grep -v '^#' | grep -v '^$')
            for plugin in $plugins
                # Skip fisher itself as it's already installed
                if test "$plugin" != "jorgebucaran/fisher"
                    echo "  Installing $plugin..."
                    fisher install $plugin
                end
            end
        end

        echo "✅ Fisher installation complete!"

    end

    # Starship custom prompt
    if type -q starship
        starship init fish | source
    end

    # Zoxide initialization
    if type -q zoxide
        zoxide init fish | source
    end

    # Custom colours
    if test -f ~/.local/state/caelestia/sequences.txt
        cat ~/.local/state/caelestia/sequences.txt 2>/dev/null | tr -d '\n'
    end

    # Caelestia shell environment
    set -gx CAELESTIA_BD_PATH /home/bestsithineu/Documents/gitProjects/shell/beat_detector
    set -gx PATH /home/bestsithineu/.local/bin/caelestia $PATH

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end
end
