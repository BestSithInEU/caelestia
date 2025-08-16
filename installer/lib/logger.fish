#!/usr/bin/env fish

# Caelestia Installer - Logging Module
# Provides structured logging with timestamps, levels, and file output

set -g CAELESTIA_LOG_LEVEL "info"
set -g CAELESTIA_LOG_FILE ""
set -g CAELESTIA_LOG_CONSOLE true
set -g CAELESTIA_LOG_TIMESTAMP true

# Log levels (numeric for comparison)
set -g LOG_LEVELS_DEBUG 0
set -g LOG_LEVELS_INFO 1  
set -g LOG_LEVELS_WARN 2
set -g LOG_LEVELS_ERROR 3

function _log_level_to_num -a level
    switch $level
        case "debug"
            echo 0
        case "info"
            echo 1
        case "warn"
            echo 2
        case "error"
            echo 3
        case "*"
            echo 1
    end
end

function _log_get_timestamp
    if test "$CAELESTIA_LOG_TIMESTAMP" = "true"
        date '+[%Y-%m-%d %H:%M:%S]'
    end
end

function _log_get_color -a level
    switch $level
        case "debug"
            echo "brblack"
        case "info"
            echo "cyan"
        case "warn"
            echo "yellow"
        case "error"
            echo "red"
        case "*"
            echo "normal"
    end
end

function _log_should_log -a level
    set -l current_level_num (_log_level_to_num $CAELESTIA_LOG_LEVEL)
    set -l message_level_num (_log_level_to_num $level)
    test $message_level_num -ge $current_level_num
end

function _log_write -a level message
    if not _log_should_log $level
        return
    end
    
    set -l timestamp (_log_get_timestamp)
    set -l level_upper (string upper $level)
    set -l log_line "$timestamp [$level_upper] $message"
    
    # Console output with colors
    if test "$CAELESTIA_LOG_CONSOLE" = "true"
        set -l color (_log_get_color $level)
        set_color $color
        echo ":: $message"
        set_color normal
    end
    
    # File output
    if test -n "$CAELESTIA_LOG_FILE"
        set -l log_dir (dirname $CAELESTIA_LOG_FILE)
        if not test -d $log_dir
            mkdir -p $log_dir
        end
        echo $log_line >> $CAELESTIA_LOG_FILE
    end
end

# Public logging functions
function log_debug -a message
    _log_write "debug" $message
end

function log_info -a message  
    _log_write "info" $message
end

function log_warn -a message
    _log_write "warn" $message
end

function log_error -a message
    _log_write "error" $message
end

function log_success -a message
    set_color green
    echo "✓ $message"
    set_color normal
    _log_write "info" "SUCCESS: $message"
end

function log_step -a step total message
    set_color blue
    echo "[$step/$total] $message"
    set_color normal
    _log_write "info" "STEP [$step/$total]: $message"
end

# Initialize logging from config
function log_init -a config_file
    if test -f $config_file
        set -g CAELESTIA_LOG_LEVEL (yq -r '.installation.logging.level // "info"' $config_file)
        set -g CAELESTIA_LOG_FILE (yq -r '.installation.logging.file // ""' $config_file)
        set -g CAELESTIA_LOG_CONSOLE (yq -r '.installation.logging.console // true' $config_file)
        set -g CAELESTIA_LOG_TIMESTAMP (yq -r '.installation.logging.timestamp // true' $config_file)
        
        # Expand home directory in log file path
        if string match -q "~*" $CAELESTIA_LOG_FILE
            set -g CAELESTIA_LOG_FILE (string replace "~" $HOME $CAELESTIA_LOG_FILE)
        end
        
        log_debug "Logging initialized - Level: $CAELESTIA_LOG_LEVEL, File: $CAELESTIA_LOG_FILE"
    end
end