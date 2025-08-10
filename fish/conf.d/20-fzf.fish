# FZF Configuration

# Default command for file listing
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'

# Preview settings
set -gx FZF_CTRL_T_OPTS "--preview 'bat --style=numbers --color=always --line-range :500 {}' --preview-window=right:60%:wrap"
set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --icons --level=2 --color=always {}' --preview-window=right:60%"
set -gx FZF_CTRL_R_OPTS "--preview 'echo {}' --preview-window=down:3:hidden:wrap --bind '?:toggle-preview'"

# Key bindings (these work with fzf.fish plugin)
bind \ct '_fzf_search_directory'
bind \cr '_fzf_search_history'
bind \ec '_fzf_search_directory'
bind \eC '_fzf_search_directory --hidden'
bind \ev '_fzf_search_shell_variables'
bind \el '_fzf_search_git_log'
bind \es '_fzf_search_git_status'

# Custom FZF functions
function fzf-preview
    fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
end

function fzf-cd
    set dir (fd --type d --hidden --follow --exclude .git | fzf --preview 'eza --tree --icons --level=2 --color=always {}')
    if test -n "$dir"
        cd $dir
    end
end

function fzf-history
    history | fzf --tac --no-sort | read -l command
    if test -n "$command"
        commandline -r $command
    end
end

function fzf-kill
    set pid (ps aux | sed 1d | fzf -m | awk '{print $2}')
    if test -n "$pid"
        echo $pid | xargs kill -9
    end
end

function fzf-git-branch
    git branch -a | grep -v HEAD | fzf | sed 's/.* //' | sed 's#remotes/[^/]*/##' | read -l branch
    if test -n "$branch"
        git checkout $branch
    end
end

function fzf-git-commit
    git log --oneline | fzf --preview 'git show --color=always {1}' | awk '{print $1}' | read -l commit
    if test -n "$commit"
        git show $commit
    end
end

# Aliases for FZF functions
alias fcd fzf-cd
alias fh fzf-history
alias fkill fzf-kill
alias fgb fzf-git-branch
alias fgc fzf-git-commit
