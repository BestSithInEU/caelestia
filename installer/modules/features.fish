#!/usr/bin/env fish

# Caelestia Installer - Features Module
# Handles installation of optional features like Spotify, VSCode, etc.

function install_spotify -a config_file
    log_info "Installing Spotify with Spicetify..."
    
    set -l packages (yq -r '.installation.features.spotify.packages[]' $config_file)
    
    # Check if spicetify-cli was already installed
    set -l has_spicetify (pacman -Q spicetify-cli 2>/dev/null)
    
    # Install packages
    log_step 1 4 "Installing Spotify packages"
    for package in $packages
        if not install_package $package
            log_error "Failed to install $package"
            return 1
        end
    end
    
    # Set permissions if this is a new spicetify installation
    if test -z "$has_spicetify"
        log_step 2 4 "Setting Spotify permissions for Spicetify"
        if not run_command "Setting Spotify permissions" "sudo chmod a+wr /opt/spotify && sudo chmod a+wr /opt/spotify/Apps -R"
            log_error "Failed to set Spotify permissions"
            return 1
        end
        
        log_step 3 4 "Initializing Spicetify"
        if not run_command "Spicetify backup and apply" "spicetify backup apply"
            log_error "Failed to initialize Spicetify"
            return 1
        end
    end
    
    # Install Spicetify configuration
    log_step 4 4 "Installing Spicetify configuration"
    set -l spicetify_config (expand_path "~/.config/spicetify")
    set -l project_root (dirname (status filename))/../..
    
    if create_symlink $project_root/spicetify $spicetify_config
        log_info "Applying Spicetify theme configuration..."
        if run_command "Setting Spicetify theme" "spicetify config current_theme caelestia color_scheme caelestia custom_apps marketplace"
            if run_command "Applying Spicetify configuration" "spicetify apply"
                log_success "Spotify with Spicetify installed successfully"
                return 0
            else
                log_error "Failed to apply Spicetify configuration"
                return 1
            end
        else
            log_error "Failed to set Spicetify theme"
            return 1
        end
    else
        log_error "Failed to install Spicetify configuration"
        return 1
    end
end

function install_vscode -a config_file variant
    log_info "Installing VSCode ($variant)..."
    
    set -l packages
    set -l prog_name
    set -l config_folder
    
    switch $variant
        case "codium"
            set packages (yq -r '.installation.features.vscode.packages_codium[]' $config_file)
            set prog_name "codium"
            set config_folder "VSCodium"
        case "code"
            set packages (yq -r '.installation.features.vscode.packages_code[]' $config_file)
            set prog_name "code"
            set config_folder "Code"
        case "vscode"
            set packages (yq -r '.installation.features.vscode.packages_vscode[]' $config_file)
            set prog_name "code"
            set config_folder "Code"
        case "*"
            log_error "Invalid VSCode variant: $variant"
            return 1
    end
    
    # Install packages
    log_step 1 3 "Installing VSCode packages"
    for package in $packages
        if not install_package $package
            log_error "Failed to install $package"
            return 1
        end
    end
    
    # Setup configuration paths
    set -l vscode_config_dir (expand_path "~/.config/$config_folder/User")
    set -l project_root (dirname (status filename))/../..
    
    # Install configuration files
    log_step 2 3 "Installing VSCode configuration"
    if not test -d $vscode_config_dir
        mkdir -p $vscode_config_dir
    end
    
    # Install settings and keybindings
    set -l success true
    if not create_symlink $project_root/vscode/settings.json $vscode_config_dir/settings.json
        set success false
    end
    
    if not create_symlink $project_root/vscode/keybindings.json $vscode_config_dir/keybindings.json
        set success false
    end
    
    # Install flags configuration
    set -l flags_config (expand_path "~/.config/$prog_name-flags.conf")
    if not create_symlink $project_root/vscode/flags.conf $flags_config
        set success false
    end
    
    if test "$success" = "false"
        log_warn "Some VSCode configuration files were not installed"
    end
    
    # Install VSCode extension
    log_step 3 3 "Installing Caelestia VSCode extension"
    set -l extension_file $project_root/vscode/caelestia-vscode-integration/caelestia-vscode-integration-*.vsix
    
    if test -f $extension_file
        if run_command "Installing VSCode extension" "$prog_name --install-extension $extension_file"
            log_success "VSCode with Caelestia integration installed successfully"
            return 0
        else
            log_warn "Failed to install VSCode extension (non-critical)"
        end
    else
        log_warn "VSCode extension file not found"
    end
    
    log_success "VSCode installed successfully"
    return 0
end

function install_discord -a config_file
    log_info "Installing Discord with Equicord..."
    
    set -l packages (yq -r '.installation.features.discord.packages[]' $config_file)
    
    # Install packages
    log_step 1 3 "Installing Discord packages"
    for package in $packages
        if not install_package $package
            log_error "Failed to install $package"
            return 1
        end
    end
    
    # Install Equicord and OpenAsar
    log_step 2 3 "Installing Equicord modifications"
    if not run_command "Installing Equicord" "sudo Equilotl -install -location /opt/discord"
        log_error "Failed to install Equicord"
        return 1
    end
    
    if not run_command "Installing OpenAsar" "sudo Equilotl -install-openasar -location /opt/discord"
        log_error "Failed to install OpenAsar"
        return 1
    end
    
    # Clean up installer
    log_step 3 3 "Cleaning up installation files"
    run_command "Removing Equicord installer" "$CAELESTIA_AUR_HELPER -Rns equicord-installer-bin --noconfirm"
    
    log_success "Discord with Equicord installed successfully"
    return 0
end

function install_zen -a config_file
    log_info "Installing Zen browser..."
    
    set -l packages (yq -r '.installation.features.zen.packages[]' $config_file)
    
    # Install packages
    log_step 1 4 "Installing Zen browser packages"
    for package in $packages
        if not install_package $package
            log_error "Failed to install $package"
            return 1
        end
    end
    
    set -l project_root (dirname (status filename))/../..
    
    # Install userChrome.css
    log_step 2 4 "Installing Zen userChrome customization"
    set -l zen_profile_dirs (expand_path "~/.zen/*/chrome")
    
    # Find the first available chrome directory
    for chrome_dir in $zen_profile_dirs
        if test -d (dirname $chrome_dir)  # Check if profile directory exists
            if not test -d $chrome_dir
                mkdir -p $chrome_dir
            end
            
            if create_symlink $project_root/zen/userChrome.css $chrome_dir/userChrome.css
                log_success "Zen userChrome installed"
                break
            end
        end
    end
    
    # Install native messaging app
    log_step 3 4 "Installing CaelestiaFox native messaging app"
    set -l hosts_dir (expand_path "~/.mozilla/native-messaging-hosts")
    set -l lib_dir (expand_path "~/.local/lib/caelestia")
    
    if not test -d $hosts_dir
        mkdir -p $hosts_dir
    end
    
    if not test -d $lib_dir
        mkdir -p $lib_dir
    end
    
    # Install manifest with path substitution
    set -l manifest_target $hosts_dir/caelestiafox.json
    if confirm_overwrite $manifest_target
        cp $project_root/zen/native_app/manifest.json $manifest_target
        sed -i "s|{{ \$lib }}|$lib_dir|g" $manifest_target
        log_debug "Native messaging manifest installed"
    end
    
    # Install native app
    if create_symlink $project_root/zen/native_app/app.fish $lib_dir/caelestiafox
        log_debug "Native messaging app installed"
    end
    
    log_step 4 4 "Installation completed"
    log_info "Please install the CaelestiaFox extension from:"
    log_info "https://addons.mozilla.org/en-US/firefox/addon/caelestiafox"
    
    log_success "Zen browser with CaelestiaFox integration installed successfully"
    return 0
end

function install_feature -a feature config_file variant
    switch $feature
        case "spotify"
            install_spotify $config_file
        case "vscode"
            set -l vscode_variant $variant
            if test -z "$vscode_variant"
                set vscode_variant (yq -r '.installation.features.vscode.variant // "codium"' $config_file)
            end
            install_vscode $config_file $vscode_variant
        case "discord"
            install_discord $config_file
        case "zen"
            install_zen $config_file
        case "*"
            log_error "Unknown feature: $feature"
            return 1
    end
end