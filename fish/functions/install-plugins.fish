function install-plugins --description 'Install all plugins from fish_plugins file'
    if not functions -q fisher
        echo "❌ Fisher not installed. Please install Fisher first."
        return 1
    end
    
    set -l config_dir (dirname (status filename))/../
    
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
        
        echo "✅ Plugin installation complete!"
    else
        echo "❌ fish_plugins file not found"
        return 1
    end
end