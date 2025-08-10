#!/usr/bin/env fish
# Generate Ghostty config from template using current caelestia scheme

# Get paths
set -q XDG_STATE_HOME && set -l state $XDG_STATE_HOME || set -l state $HOME/.local/state
set -l scheme_path $state/caelestia/scheme.json
set -l template_path (dirname (status -f))/config.template
set -l config_path (dirname (status -f))/config

# Check if scheme exists
if not test -f $scheme_path
    echo "No caelestia scheme found at $scheme_path" >&2
    exit 1
end

# Check if template exists
if not test -f $template_path
    echo "Template not found at $template_path" >&2
    exit 1
end

# Parse scheme JSON and generate config
if not command -q jq
    echo "jq is required but not installed" >&2
    exit 1
end

# Read template
set -l template_content (cat $template_path)

# Extract colors from scheme
set -l colors (jq -r '.colours | to_entries | .[] | "\(.key)=\(.value)"' $scheme_path)

# Replace placeholders in template
set -l generated_config $template_content
for color in $colors
    set -l key (string split = $color)[1]
    set -l value (string split = $color)[2]
    set generated_config (string replace -a "{{$key}}" "$value" $generated_config)
end

# Write generated config
printf '%s\n' $generated_config > $config_path

echo "Generated Ghostty config from caelestia scheme"