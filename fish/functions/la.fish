function la --description 'List all directory contents including hidden'
    eza -la --icons --group-directories-first --git $argv
end