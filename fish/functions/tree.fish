function tree --description 'Display directory tree structure with optional depth'
    # Check if first argument is a number (depth)
    if test (count $argv) -gt 0; and string match -qr '^\d+$' -- $argv[1]
        eza --tree --icons --level=$argv[1] $argv[2..-1]
    else
        eza --tree --icons $argv
    end
end
