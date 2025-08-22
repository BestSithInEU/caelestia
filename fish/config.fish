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

# Wine gaming environment for Hyprland
set -gx WINE_GAMES_PREFIX "$HOME/.wine-games"

# Wine functions for gaming
function wine-game
    env WAYLAND_DISPLAY= DISPLAY=:0 SDL_VIDEODRIVER=x11 WINEPREFIX=$WINE_GAMES_PREFIX wine explorer /desktop=Default,1920x1080 $argv
end

function wine-renpy
    env WAYLAND_DISPLAY= DISPLAY=:0 SDL_VIDEODRIVER=x11 RENPY_RENDERER=sw RENPY_GL_TEST_ENV=1 RENPY_SKIP_GL_TEST=1 RENPY_GL_SKIP_TEST=1 RENPY_FORCE_SW_RENDERER=1 RENPY_GL_DISABLE=1 MESA_SOFTWARE=1 LIBGL_ALWAYS_SOFTWARE=1 wine explorer /desktop=Default,1920x1080 $argv
end

function wine-unity
    env WAYLAND_DISPLAY= DISPLAY=:0 SDL_VIDEODRIVER=x11 DXVK_HUD=fps WINEPREFIX=$WINE_GAMES_PREFIX wine explorer /desktop=Default,1920x1080 $argv
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
# Add sonar-scanner to PATH
set -gx SONAR_SCANNER_HOME "/opt/sonar-scanner"
set -gx PATH "$SONAR_SCANNER_HOME/bin" $PATH
