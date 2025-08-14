# Ollama command completion for fish shell

# Main commands
complete -c ollama -f -n __fish_use_subcommand -a serve -d "Start ollama"
complete -c ollama -f -n __fish_use_subcommand -a start -d "Start ollama (alias for serve)"
complete -c ollama -f -n __fish_use_subcommand -a create -d "Create a model"
complete -c ollama -f -n __fish_use_subcommand -a show -d "Show information for a model"
complete -c ollama -f -n __fish_use_subcommand -a run -d "Run a model"
complete -c ollama -f -n __fish_use_subcommand -a stop -d "Stop a running model"
complete -c ollama -f -n __fish_use_subcommand -a pull -d "Pull a model from a registry"
complete -c ollama -f -n __fish_use_subcommand -a push -d "Push a model to a registry"
complete -c ollama -f -n __fish_use_subcommand -a list -d "List models"
complete -c ollama -f -n __fish_use_subcommand -a ls -d "List models (alias for list)"
complete -c ollama -f -n __fish_use_subcommand -a ps -d "List running models"
complete -c ollama -f -n __fish_use_subcommand -a cp -d "Copy a model"
complete -c ollama -f -n __fish_use_subcommand -a rm -d "Remove a model"
complete -c ollama -f -n __fish_use_subcommand -a help -d "Help about any command"

# Global flags
complete -c ollama -l help -s h -d "Help for ollama"
complete -c ollama -l version -s v -d "Show version information"

# Serve/Start command (serve and start are aliases)
complete -c ollama -f -n "__fish_seen_subcommand_from serve start" -l help -s h -d "Help for serve"

# Create command
complete -c ollama -f -n "__fish_seen_subcommand_from create" -l file -s f -d "Name of the Modelfile (default \"Modelfile\")"
complete -c ollama -f -n "__fish_seen_subcommand_from create" -l quantize -s q -d "Quantize model to this level (e.g. q4_K_M)"
complete -c ollama -f -n "__fish_seen_subcommand_from create" -l help -s h -d "Help for create"

# Show command
complete -c ollama -f -n "__fish_seen_subcommand_from show" -l help -s h -d "Help for show"
complete -c ollama -f -n "__fish_seen_subcommand_from show" -l license -d "Show license of a model"
complete -c ollama -f -n "__fish_seen_subcommand_from show" -l modelfile -d "Show Modelfile of a model"
complete -c ollama -f -n "__fish_seen_subcommand_from show" -l parameters -d "Show parameters of a model"
complete -c ollama -f -n "__fish_seen_subcommand_from show" -l system -d "Show system message of a model"
complete -c ollama -f -n "__fish_seen_subcommand_from show" -l template -d "Show template of a model"
complete -c ollama -f -n "__fish_seen_subcommand_from show" -l verbose -s v -d "Show detailed model information"

# Run command
complete -c ollama -f -n "__fish_seen_subcommand_from run" -l format -d "Response format (e.g. json)"
complete -c ollama -f -n "__fish_seen_subcommand_from run" -l help -s h -d "Help for run"
complete -c ollama -f -n "__fish_seen_subcommand_from run" -l hidethinking -d "Hide thinking output (if provided)"
complete -c ollama -f -n "__fish_seen_subcommand_from run" -l insecure -d "Use an insecure registry"
complete -c ollama -f -n "__fish_seen_subcommand_from run" -l keepalive -d "Duration to keep a model loaded (e.g. 5m)"
complete -c ollama -f -n "__fish_seen_subcommand_from run" -l nowordwrap -d "Don't wrap words to the next line automatically"
complete -c ollama -f -n "__fish_seen_subcommand_from run" -l think -d "Enable thinking mode: true/false or high/medium/low for supported models"
complete -c ollama -f -n "__fish_seen_subcommand_from run" -l verbose -d "Show timings for response"

# Stop command
complete -c ollama -f -n "__fish_seen_subcommand_from stop" -l help -s h -d "Help for stop"

# Pull command
complete -c ollama -f -n "__fish_seen_subcommand_from pull" -l help -s h -d "Help for pull"
complete -c ollama -f -n "__fish_seen_subcommand_from pull" -l insecure -d "Use an insecure registry"

# Push command  
complete -c ollama -f -n "__fish_seen_subcommand_from push" -l help -s h -d "Help for push"
complete -c ollama -f -n "__fish_seen_subcommand_from push" -l insecure -d "Use an insecure registry"

# List/ls command (list and ls are aliases)
complete -c ollama -f -n "__fish_seen_subcommand_from list ls" -l help -s h -d "Help for list"

# PS command
complete -c ollama -f -n "__fish_seen_subcommand_from ps" -l help -s h -d "Help for ps"

# CP command
complete -c ollama -f -n "__fish_seen_subcommand_from cp" -l help -s h -d "Help for cp"

# RM command
complete -c ollama -f -n "__fish_seen_subcommand_from rm" -l help -s h -d "Help for rm"

# Dynamic model name completion for commands that need it
function __fish_ollama_models
    ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' | cut -d':' -f1 | sort -u
end

# Commands that need model names
complete -c ollama -f -n "__fish_seen_subcommand_from run pull push show rm stop" -a "(__fish_ollama_models)"

# For cp command, we need source and destination
complete -c ollama -f -n "__fish_seen_subcommand_from cp; and __fish_is_first_arg" -a "(__fish_ollama_models)"
complete -c ollama -f -n "__fish_seen_subcommand_from cp; and not __fish_is_first_arg" -a "(__fish_ollama_models)"

# For create command, suggest model names
complete -c ollama -f -n "__fish_seen_subcommand_from create" -a "(__fish_ollama_models)"