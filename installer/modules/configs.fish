#!/usr/bin/env fish

# Caelestia Installer - Configuration Module
# Handles installation of configuration files and directories

function install_shell_components
    log_info "Setting up caelestia shell components..."
    
    set -l shell_dir (dirname (status filename))/../../shell
    
    if not test -d $shell_dir
        log_error "Shell directory not found: $shell_dir"
        return 1
    end
    
    pushd $shell_dir
    
    # Compile beat detector
    log_step 1 3 "Compiling beat detector"
    set -l beat_detector_src assets/beat_detector.cpp
    set -l beat_detector_bin beat_detector
    
    if not test -f $beat_detector_src
        log_error "Beat detector source not found: $beat_detector_src"
        popd
        return 1
    end
    
    if not g++ -std=c++17 -Wall -Wextra \
        -I/usr/include/pipewire-0.3 \
        -I/usr/include/spa-0.2 \
        -I/usr/include/aubio \
        -o $beat_detector_bin $beat_detector_src \
        -lpipewire-0.3 -laubio
        log_error "Failed to compile beat detector"
        popd
        return 1
    end
    
    # Install beat detector to system
    log_step 2 3 "Installing beat detector to system"
    if not sudo mkdir -p /usr/lib/caelestia
        log_error "Failed to create system directory"
        popd
        return 1
    end
    
    set -l beat_detector_path (realpath $beat_detector_bin)
    if not sudo ln -sf $beat_detector_path /usr/lib/caelestia/beat_detector
        log_error "Failed to install beat detector"
        popd
        return 1
    end
    
    # Create quickshell config symlink
    log_step 3 3 "Setting up quickshell configuration"
    set -l quickshell_config_dir (expand_path "~/.config/quickshell")
    
    if not test -d $quickshell_config_dir
        mkdir -p $quickshell_config_dir
    end
    
    set -l shell_realpath (realpath .)
    if create_symlink $shell_realpath $quickshell_config_dir/caelestia
        log_success "Shell components installed successfully"
        popd
        return 0
    else
        log_error "Failed to create quickshell symlink"
        popd
        return 1
    end
end

function install_single_config -a config_obj
    set -l name (echo $config_obj | yq -r '.name')
    set -l source (echo $config_obj | yq -r '.source')
    set -l target (echo $config_obj | yq -r '.target')
    set -l reload_command (echo $config_obj | yq -r '.reload_command // empty')
    
    log_info "Installing $name configuration..."
    
    set -l project_root (dirname (status filename))/../..
    set -l source_path $project_root/$source
    
    if not test -e $source_path
        log_error "Source path does not exist: $source_path"
        return 1
    end
    
    if create_symlink $source_path $target
        log_success "$name configuration installed"
        
        # Run reload command if specified
        if test -n "$reload_command"
            log_debug "Running reload command: $reload_command"
            if run_command "Reloading $name" "$reload_command"
                log_debug "$name reloaded successfully"
            else
                log_warn "Failed to reload $name (non-critical)"
            end
        end
        
        return 0
    else
        log_warn "$name configuration installation skipped"
        return 1
    end
end

function install_configurations -a config_file
    log_info "Installing configuration files..."
    
    set -l configs (yq -r '.installation.configs[]' $config_file 2>/dev/null)
    
    if test (count $configs) -eq 0
        log_warn "No configurations defined in config file"
        return 0
    end
    
    set -l total (count $configs)
    set -l current 0
    set -l installed 0
    
    for config_yaml in $configs
        set current (math $current + 1)
        log_step $current $total "Processing configuration entry"
        
        if install_single_config "$config_yaml"
            set installed (math $installed + 1)
        end
    end
    
    log_info "Configuration installation completed ($installed/$total installed)"
    return 0
end

function setup_scheme
    log_info "Setting up initial color scheme..."
    
    set -l state_dir (expand_path "~/.local/state/caelestia")
    set -l scheme_file $state_dir/scheme.json
    
    if test -f $scheme_file
        log_debug "Color scheme already configured"
        return 0
    end
    
    # Create state directory
    if not test -d $state_dir
        mkdir -p $state_dir
    end
    
    # Set default scheme
    if check_command caelestia
        log_info "Setting default color scheme..."
        if caelestia scheme set -n shadotheme
            sleep 0.5
            if check_command hyprctl
                hyprctl reload >/dev/null 2>&1
            end
            log_success "Default color scheme applied"
        else
            log_warn "Failed to set default color scheme"
        end
    else
        log_warn "caelestia command not available, skipping scheme setup"
    end
    
    return 0
end

function start_caelestia_shell
    log_info "Starting caelestia shell..."
    
    if check_command caelestia
        if caelestia shell -d >/dev/null 2>&1
            log_success "Caelestia shell started successfully"
        else
            log_warn "Failed to start caelestia shell (non-critical)"
        end
    else
        log_warn "caelestia command not available, cannot start shell"
    end
end

function setup_configurations -a config_file
    log_info "Setting up configurations..."
    
    # Install shell components first
    if not install_shell_components
        log_error "Failed to install shell components"
        return 1
    end
    
    # Install configuration files
    install_configurations $config_file
    
    # Setup color scheme
    setup_scheme
    
    # Start shell
    start_caelestia_shell
    
    log_success "Configuration setup completed"
    return 0
end