#!/usr/bin/env fish
# Watch caelestia scheme changes and regenerate Ghostty config

# Get paths
set -q XDG_STATE_HOME && set -l state $XDG_STATE_HOME || set -l state $HOME/.local/state
set -l scheme_dir $state/caelestia
set -l scheme_path $scheme_dir/scheme.json
set -l generator_script (dirname (status -f))/generate-config.fish

# Check if generator script exists
if not test -f $generator_script
    echo "Generator script not found at $generator_script" >&2
    exit 1
end

# Check if inotifywait is available
if not command -q inotifywait
    echo "inotifywait is required but not installed" >&2
    echo "Install with: sudo pacman -S inotify-tools" >&2
    exit 1
end

echo "Watching $scheme_path for changes..."

# Generate initial config if scheme exists
if test -f $scheme_path
    $generator_script
    echo "Generated initial Ghostty config"
end

# Watch for scheme changes and regenerate config
inotifywait -q -e 'close_write,moved_to,create' -m $scheme_dir | while read dir events file
    if test "$dir$file" = $scheme_path
        echo "Scheme changed, regenerating Ghostty config..."
        $generator_script
    end
end