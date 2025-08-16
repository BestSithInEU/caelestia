#!/usr/bin/env fish

# Caelestia Installer - Backup and Rollback Module
# Provides backup functionality and rollback capabilities

set -g CAELESTIA_BACKUP_DIR ""
set -g CAELESTIA_BACKUP_ENABLED false
set -g CAELESTIA_BACKUP_MANIFEST ""

function backup_init -a config_file
    set -g CAELESTIA_BACKUP_ENABLED (get_config_value $config_file ".installation.backup.enabled" "true")
    
    if test "$CAELESTIA_BACKUP_ENABLED" != "true"
        log_debug "Backup disabled in configuration"
        return 0
    end
    
    set -g CAELESTIA_BACKUP_DIR (get_config_value $config_file ".installation.backup.directory" "~/.config.bak")
    set -g CAELESTIA_BACKUP_DIR (expand_path $CAELESTIA_BACKUP_DIR)
    set -g CAELESTIA_BACKUP_MANIFEST "$CAELESTIA_BACKUP_DIR/.caelestia_backup_manifest"
    
    log_debug "Backup initialized - Directory: $CAELESTIA_BACKUP_DIR"
    
    # Create backup directory
    if not test -d $CAELESTIA_BACKUP_DIR
        mkdir -p $CAELESTIA_BACKUP_DIR
    end
    
    # Initialize manifest
    if not test -f $CAELESTIA_BACKUP_MANIFEST
        echo "# Caelestia Backup Manifest - "(date)" > $CAELESTIA_BACKUP_MANIFEST
        echo "# Format: TYPE:SOURCE:TARGET:TIMESTAMP" >> $CAELESTIA_BACKUP_MANIFEST
    end
end

function backup_add_entry -a type source target
    if test "$CAELESTIA_BACKUP_ENABLED" != "true"
        return 0
    end
    
    set -l timestamp (date '+%Y-%m-%d_%H:%M:%S')
    echo "$type:$source:$target:$timestamp" >> $CAELESTIA_BACKUP_MANIFEST
    log_debug "Added backup entry: $type:$source:$target"
end

function backup_file -a file_path
    if test "$CAELESTIA_BACKUP_ENABLED" != "true"
        return 0
    end
    
    set -l file_expanded (expand_path $file_path)
    
    if not test -e $file_expanded
        log_debug "File doesn't exist, no backup needed: $file_expanded"
        return 0
    end
    
    # Create relative path for backup
    set -l relative_path (string replace $HOME "" $file_expanded)
    if test "$relative_path" = "$file_expanded"
        # File is outside home directory, use absolute path with prefix
        set relative_path "root$file_expanded"
    end
    
    set -l backup_path "$CAELESTIA_BACKUP_DIR$relative_path"
    set -l backup_dir (dirname $backup_path)
    
    # Create backup directory structure
    if not test -d $backup_dir
        mkdir -p $backup_dir
    end
    
    # Check if backup already exists
    if test -e $backup_path
        if not confirm_action "Backup already exists for $file_path. Overwrite?"
            log_info "Skipped backup for $file_path"
            return 1
        end
    end
    
    # Create backup
    log_debug "Backing up: $file_expanded -> $backup_path"
    if cp -r $file_expanded $backup_path
        backup_add_entry "file" $file_expanded $backup_path
        log_debug "Successfully backed up: $file_path"
        return 0
    else
        log_error "Failed to backup: $file_path"
        return 1
    end
end

function backup_directory -a dir_path
    if test "$CAELESTIA_BACKUP_ENABLED" != "true"
        return 0
    end
    
    backup_file $dir_path  # Use same logic as file backup
end

function backup_config_directory -a config_path
    set -l config_expanded (expand_path $config_path)
    
    if not test -e $config_expanded
        log_debug "Config directory doesn't exist: $config_expanded"
        return 0
    end
    
    log_info "Backing up configuration: $config_path"
    backup_directory $config_expanded
end

function create_full_backup -a config_file
    if test "$CAELESTIA_BACKUP_ENABLED" != "true"
        log_info "Backup disabled, skipping full backup"
        return 0
    end
    
    set -l should_prompt (get_config_value $config_file ".installation.backup.prompt" "true")
    
    if test "$should_prompt" = "true" -a "$CAELESTIA_NOCONFIRM" != "true"
        log_info "Backup options:"
        log_info "[1] I already have a backup"
        log_info "[2] Create a full backup now"
        
        read -l -p "set_color blue; echo -n '=> '; set_color normal" choice
        
        switch $choice
            case "1"
                log_info "Proceeding without creating backup"
                return 0
            case "2"
                # Continue with backup creation
            case "*"
                log_error "Invalid choice. Exiting..."
                return 1
        end
    end
    
    log_info "Creating full configuration backup..."
    set -l config_dir (expand_path "~/.config")
    
    if backup_directory $config_dir
        log_success "Full configuration backup created"
        return 0
    else
        log_error "Failed to create full backup"
        return 1
    end
end

function rollback_from_manifest
    if not test -f $CAELESTIA_BACKUP_MANIFEST
        log_error "No backup manifest found for rollback"
        return 1
    end
    
    log_info "Starting rollback process..."
    
    set -l entries (grep -v '^#' $CAELESTIA_BACKUP_MANIFEST | tac)  # Reverse order for rollback
    set -l total (count $entries)
    set -l current 0
    
    for entry in $entries
        set current (math $current + 1)
        
        set -l parts (string split ":" $entry)
        set -l type $parts[1]
        set -l source $parts[2]
        set -l target $parts[3]
        
        log_step $current $total "Rolling back: $source"
        
        # Remove current file/directory
        if test -e $source -o -L $source
            rm -rf $source
        end
        
        # Restore from backup
        if test -e $target
            if cp -r $target $source
                log_debug "Restored: $source"
            else
                log_error "Failed to restore: $source"
            end
        else
            log_warn "Backup file not found: $target"
        end
    end
    
    log_success "Rollback completed"
    return 0
end

function cleanup_backups -a days_old
    if test "$CAELESTIA_BACKUP_ENABLED" != "true"
        return 0
    end
    
    if test -z "$days_old"
        set days_old 30
    end
    
    log_info "Cleaning up backups older than $days_old days..."
    
    if test -d $CAELESTIA_BACKUP_DIR
        find $CAELESTIA_BACKUP_DIR -type f -mtime +$days_old -delete 2>/dev/null
        find $CAELESTIA_BACKUP_DIR -type d -empty -delete 2>/dev/null
        log_debug "Backup cleanup completed"
    end
end

function list_backups
    if not test -f $CAELESTIA_BACKUP_MANIFEST
        log_info "No backup manifest found"
        return 0
    end
    
    log_info "Backup history:"
    grep -v '^#' $CAELESTIA_BACKUP_MANIFEST | while read -l entry
        set -l parts (string split ":" $entry)
        set -l type $parts[1]
        set -l source $parts[2] 
        set -l timestamp $parts[4]
        echo "  $timestamp - $type: $source"
    end
end