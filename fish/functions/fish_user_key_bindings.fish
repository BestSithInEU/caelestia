function fish_user_key_bindings
    # Ctrl+R for history search with fzf
    bind \cr '_fzf_search_history'

    # Ctrl+T for file search
    bind \ct '_fzf_search_directory'

    # Alt+C for directory navigation
    bind \ec '_fzf_search_directory'

    # Ctrl+G for git status files
    bind \cg '_fzf_search_git_status'

    # Alt+L for git log
    bind \el '_fzf_search_git_log'

    # Ctrl+K to clear screen
    bind \ck 'clear; commandline -f repaint'

    # Alt+E to open command in editor
    bind \ee 'edit_command_buffer'

    # Alt+P for process search
    bind \ep '_fzf_search_processes'

    # Alt+S to prepend sudo
    bind \es '__fish_prepend_sudo'
end

function __fish_prepend_sudo
    set -l cmd (commandline -b)
    if test -z "$cmd"
        commandline -r "sudo "
    else if not string match -q "sudo *" "$cmd"
        commandline -r "sudo $cmd"
    else
        commandline -r (string replace -r "^sudo\s+" "" "$cmd")
    end
    commandline -f end-of-line
end

function _fzf_search_processes
    set -l pid (command ps aux --sort=-%cpu | fzf -m --header-lines=1 --header="Select process to kill (sorted by CPU usage)" | awk '{print $2}')
    if test -n "$pid"
        commandline -r "kill -9 $pid"
    end
end
