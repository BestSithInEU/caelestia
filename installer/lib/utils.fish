#!/usr/bin/env fish

# Caelestia Installer - Utility Functions
# Common utility functions used across installation modules

function confirm_action -a message
    if test "$CAELESTIA_NOCONFIRM" = "true"
        log_debug "Auto-confirming: $message"
        return 0
    end
    
    read -l -p "set_color blue; echo -n '? $message [Y/n] '; set_color normal" response
    
    switch $response
        case "" "y" "Y" "yes" "YES"
            return 0
        case "*"
            log_info "Action cancelled by user"
            return 1
    end
end

function confirm_overwrite -a path
    if not test -e $path -a not test -L $path
        return 0  # Path doesn't exist, no need to confirm
    end
    
    if test "$CAELESTIA_NOCONFIRM" = "true"
        log_info "Removing existing $path (auto-confirmed)"
        rm -rf $path
        return 0
    end
    
    if confirm_action "$path already exists. Overwrite?"
        log_info "Removing existing $path"
        rm -rf $path
        return 0
    else
        return 1
    end
end

function check_command -a cmd
    command -v $cmd >/dev/null 2>&1
end

function install_package -a package
    set -l aur_helper $CAELESTIA_AUR_HELPER
    set -l confirm_flag ""
    
    if test "$CAELESTIA_NOCONFIRM" = "true"
        set confirm_flag "--noconfirm"
    end
    
    log_debug "Installing package: $package"
    $aur_helper -S --needed $package $confirm_flag
    
    if test $status -eq 0
        log_debug "Successfully installed: $package"
        return 0
    else
        log_error "Failed to install: $package"
        return 1
    end
end

function install_packages -a packages_str
    set -l packages (string split " " $packages_str)
    set -l failed_packages
    
    for package in $packages
        if not install_package $package
            set -a failed_packages $package
        end
    end
    
    if test (count $failed_packages) -gt 0
        log_error "Failed to install packages: "(string join ", " $failed_packages)
        return 1
    end
    
    return 0
end

function create_symlink -a source target
    set -l source_abs (realpath $source)
    set -l target_expanded (string replace "~" $HOME $target)
    set -l target_dir (dirname $target_expanded)
    
    # Create target directory if it doesn't exist
    if not test -d $target_dir
        log_debug "Creating directory: $target_dir"
        mkdir -p $target_dir
    end
    
    if confirm_overwrite $target_expanded
        log_info "Creating symlink: $target_expanded -> $source_abs"
        ln -sf $source_abs $target_expanded
        return 0
    else
        log_warn "Skipped symlink creation: $target_expanded"
        return 1
    end
end

function backup_config -a config_path backup_dir
    set -l config_expanded (string replace "~" $HOME $config_path)
    set -l backup_expanded (string replace "~" $HOME $backup_dir)
    
    if not test -e $config_expanded
        log_debug "Config path doesn't exist, skipping backup: $config_expanded"
        return 0
    end
    
    if not test -d (dirname $backup_expanded)
        mkdir -p (dirname $backup_expanded)
    end
    
    if test -e $backup_expanded
        if not confirm_action "Backup already exists at $backup_expanded. Overwrite?"
            return 1
        end
        rm -rf $backup_expanded
    end
    
    log_info "Backing up $config_expanded to $backup_expanded"
    cp -r $config_expanded $backup_expanded
    return $status
end

function run_command -a description cmd
    log_debug "Running: $cmd"
    
    if eval $cmd
        log_debug "Command succeeded: $description"
        return 0
    else
        log_error "Command failed: $description"
        return 1
    end
end

function expand_path -a path
    string replace "~" $HOME $path
end

function get_config_value -a config_file key default_value
    if test -f $config_file
        set -l value (yq -r "$key // \"$default_value\"" $config_file)
        echo $value
    else
        echo $default_value
    end
end