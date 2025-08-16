#!/usr/bin/env fish

# Caelestia Installer - Dependencies Module
# Handles installation of core dependencies and AUR helper setup

function install_aur_helper -a aur_helper
    if pacman -Q $aur_helper &>/dev/null
        log_info "$aur_helper is already installed"
        return 0
    end
    
    log_info "Installing $aur_helper..."
    log_step 1 4 "Installing base development tools"
    
    if not sudo pacman -S --needed git base-devel --noconfirm
        log_error "Failed to install base development tools"
        return 1
    end
    
    log_step 2 4 "Downloading $aur_helper from AUR"
    set -l temp_dir /tmp/$aur_helper-(random)
    
    if not git clone https://aur.archlinux.org/$aur_helper.git $temp_dir
        log_error "Failed to clone $aur_helper repository"
        return 1
    end
    
    log_step 3 4 "Building $aur_helper package"
    pushd $temp_dir
    
    if not makepkg -si --noconfirm
        log_error "Failed to build $aur_helper"
        popd
        rm -rf $temp_dir
        return 1
    end
    
    popd
    rm -rf $temp_dir
    
    log_step 4 4 "Configuring $aur_helper"
    $aur_helper -Y --gendb
    $aur_helper -Y --devel --save
    
    log_success "$aur_helper installed and configured successfully"
    return 0
end

function install_core_tools
    log_info "Installing core tools..."
    
    # Install uv (Python package manager)
    if not check_command uv
        log_info "Installing uv..."
        if curl -LsSf https://astral.sh/uv/install.sh | sh
            log_success "uv installed successfully"
        else
            log_error "Failed to install uv"
            return 1
        end
    else
        log_debug "uv is already installed"
    end
    
    # Install yq (YAML processor)
    if not check_command yq
        log_info "Installing yq..."
        if sudo curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/local/bin/yq && sudo chmod +x /usr/local/bin/yq
            log_success "yq installed successfully"
        else
            log_error "Failed to install yq"
            return 1
        end
    else
        log_debug "yq is already installed"
    end
    
    return 0
end

function install_core_dependencies -a config_file
    log_info "Installing core dependencies..."
    
    set -l dependencies (yq -r '.installation.core_dependencies[]' $config_file 2>/dev/null)
    
    if test (count $dependencies) -eq 0
        log_warn "No core dependencies defined in config"
        return 0
    end
    
    set -l total (count $dependencies)
    set -l current 0
    
    for dep in $dependencies
        set current (math $current + 1)
        log_step $current $total "Installing $dep"
        
        if not install_package $dep
            log_error "Failed to install core dependency: $dep"
            return 1
        end
    end
    
    log_success "All core dependencies installed successfully"
    return 0
end

function install_from_apps_yaml
    set -l apps_file (dirname (status filename))/../../apps.yaml
    
    if not test -f $apps_file
        log_warn "apps.yaml not found, skipping dependency installation"
        return 0
    end
    
    log_info "Installing dependencies from apps.yaml..."
    
    # Install core dependencies
    set -l core_deps (yq -r '.core_dependencies[]?' $apps_file 2>/dev/null)
    if test (count $core_deps) -gt 0
        log_info "Installing core dependencies from apps.yaml..."
        for pkg in $core_deps
            install_package $pkg
        end
    end
    
    # Install optional dependencies  
    set -l optional_deps (yq -r '.optional_dependencies[]?' $apps_file 2>/dev/null)
    if test (count $optional_deps) -gt 0
        log_info "Installing optional dependencies from apps.yaml..."
        for pkg in $optional_deps
            install_package $pkg
        end
    end
    
    return 0
end

function setup_dependencies -a config_file
    log_info "Setting up dependencies..."
    
    # Get AUR helper preference
    set -g CAELESTIA_AUR_HELPER (get_config_value $config_file ".installation.aur_helper" "yay")
    
    # Install AUR helper
    if not install_aur_helper $CAELESTIA_AUR_HELPER
        return 1
    end
    
    # Install core tools
    if not install_core_tools
        return 1
    end
    
    # Install dependencies from config
    if not install_core_dependencies $config_file
        return 1
    end
    
    # Install from apps.yaml if it exists
    install_from_apps_yaml
    
    log_success "Dependencies setup completed"
    return 0
end