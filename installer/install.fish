#!/usr/bin/env fish

# Caelestia Dotfiles Installer - Modular and Well-Structured
# Main installation script that orchestrates all installation modules

# Set script directory and add lib to function path
set -l installer_dir (dirname (status filename))
set -gp fish_function_path $installer_dir/lib $installer_dir/modules

# Global variables
set -g CAELESTIA_NOCONFIRM false
set -g CAELESTIA_AUR_HELPER "yay"

# Parse command line arguments
argparse -n 'install.fish' -X 0 \
    'h/help' \
    'noconfirm' \
    'spotify' \
    'vscode=?!contains -- "$_flag_value" codium code vscode' \
    'discord' \
    'zen' \
    'paru' \
    'rollback' \
    'list-backups' \
    'cleanup-backups=?' \
    'config=?' \
    -- $argv
or exit 1

# Configuration file path
set -l config_file $installer_dir/config/install.yaml
if set -q _flag_config
    set config_file $_flag_config
end

# Source all library modules
for lib_file in $installer_dir/lib/*.fish
    source $lib_file
end

# Source all installation modules  
for module_file in $installer_dir/modules/*.fish
    source $module_file
end

# Help function
function show_help
    echo 'Caelestia Dotfiles Installer'
    echo
    echo 'usage: ./installer/install.fish [OPTIONS]'
    echo
    echo 'options:'
    echo '  -h, --help                  show this help message and exit'
    echo '  --config PATH               use custom configuration file'
    echo '  --noconfirm                 do not confirm package installation'
    echo '  --paru                      use paru instead of yay as AUR helper'
    echo
    echo 'features:'
    echo '  --spotify                   install Spotify with Spicetify theming'
    echo '  --vscode=[codium|code|vscode] install VSCodium (default), Code, or VSCode'
    echo '  --discord                   install Discord with Equicord and OpenAsar'
    echo '  --zen                       install Zen browser with CaelestiaFox'
    echo
    echo 'backup and recovery:'
    echo '  --rollback                  rollback previous installation'
    echo '  --list-backups              list available backups'
    echo '  --cleanup-backups[=DAYS]    cleanup backups older than DAYS (default: 30)'
    echo
    echo 'examples:'
    echo '  ./installer/install.fish --spotify --vscode=codium'
    echo '  ./installer/install.fish --vscode=vscode --discord'
    echo '  ./installer/install.fish --noconfirm --discord --zen'
    echo '  ./installer/install.fish --rollback'
end

# Handle special operations
if set -q _flag_help
    show_help
    exit 0
end

if set -q _flag_list_backups
    log_init $config_file
    backup_init $config_file
    list_backups
    exit 0
end

if set -q _flag_cleanup_backups
    log_init $config_file  
    backup_init $config_file
    set -l days $_flag_cleanup_backups
    if test -z "$days"
        set days 30
    end
    cleanup_backups $days
    exit 0
end

if set -q _flag_rollback
    log_init $config_file
    backup_init $config_file
    
    if confirm_action "This will rollback the previous Caelestia installation. Continue?"
        rollback_from_manifest
        log_success "Rollback completed successfully"
    else
        log_info "Rollback cancelled"
    end
    exit 0
end

# Check if config file exists
if not test -f $config_file
    echo "Error: Configuration file not found: $config_file"
    echo "Use --config to specify a different configuration file."
    exit 1
end

# Set global variables from flags
set -q _flag_noconfirm && set -g CAELESTIA_NOCONFIRM true
set -q _flag_paru && set -g CAELESTIA_AUR_HELPER paru

# Initialize logging and backup systems
log_init $config_file
backup_init $config_file

# Display banner
function show_banner
    set_color magenta
    echo '╭─────────────────────────────────────────────────╮'
    echo '│      ______           __          __  _         │'
    echo '│     / ____/___ ____  / /__  _____/ /_(_)___ _   │'
    echo '│    / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/   │'
    echo '│   / /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /    │'
    echo '│   \____/\__,_/\___/_/\___/____/\__/_/\__,_/     │'
    echo '│                                                 │'
    echo '╰─────────────────────────────────────────────────╯'
    set_color normal
    echo
end

# Main installation function
function main_install
    log_info "Starting Caelestia dotfiles installation..."
    log_info "Configuration: $config_file"
    log_info "Log level: $CAELESTIA_LOG_LEVEL"
    
    # Create full backup if enabled
    if not create_full_backup $config_file
        log_error "Backup creation failed or was cancelled"
        return 1
    end
    
    # Step 1: Setup dependencies
    log_info "=== Phase 1: Dependencies ==="
    if not setup_dependencies $config_file
        log_error "Dependencies setup failed"
        return 1
    end
    
    # Step 2: Install configurations  
    log_info "=== Phase 2: Configuration Files ==="
    if not setup_configurations $config_file
        log_error "Configuration setup failed"
        return 1
    end
    
    # Step 3: Install optional features
    log_info "=== Phase 3: Optional Features ==="
    set -l features_installed 0
    
    if set -q _flag_spotify
        log_info "Installing Spotify feature..."
        if install_feature "spotify" $config_file
            set features_installed (math $features_installed + 1)
        end
    end
    
    if set -q _flag_vscode
        log_info "Installing VSCode feature..."
        if install_feature "vscode" $config_file $_flag_vscode
            set features_installed (math $features_installed + 1)
        end
    end
    
    if set -q _flag_discord
        log_info "Installing Discord feature..."
        if install_feature "discord" $config_file
            set features_installed (math $features_installed + 1)
        end
    end
    
    if set -q _flag_zen
        log_info "Installing Zen browser feature..."
        if install_feature "zen" $config_file
            set features_installed (math $features_installed + 1)
        end
    end
    
    if test $features_installed -eq 0
        log_info "No optional features selected"
    else
        log_success "$features_installed optional features installed"
    end
    
    return 0
end

# Error handler
function handle_error
    log_error "Installation failed!"
    log_info "You can:"
    log_info "  - Check the log file: $CAELESTIA_LOG_FILE"
    log_info "  - Run with --rollback to undo changes"
    log_info "  - Run with --help for usage information"
    exit 1
end

# Main execution
function main
    # Show banner
    show_banner
    
    # Welcome message and safety check
    log_info "Welcome to the Caelestia dotfiles installer!"
    log_info "This installer will set up your dotfiles with proper backup and logging."
    log_warn "Please ensure you have a backup of important configuration files."
    
    # Confirm installation start
    if not confirm_action "Ready to start installation?"
        log_info "Installation cancelled by user"
        exit 0
    end
    
    # Change to project root directory
    set -l project_root (dirname $installer_dir)
    pushd $project_root
    
    # Run main installation
    if main_install
        log_success "Caelestia dotfiles installation completed successfully!"
        log_info "You may need to restart your session for all changes to take effect."
        
        # Show post-installation information
        if set -q _flag_zen
            echo
            log_info "Post-installation steps:"
            log_info "• Install CaelestiaFox extension: https://addons.mozilla.org/en-US/firefox/addon/caelestiafox"
        end
        
        if test -n "$CAELESTIA_LOG_FILE"
            log_info "Installation log saved to: $CAELESTIA_LOG_FILE"
        end
        
    else
        handle_error
    end
    
    popd
end

# Execute main function
main