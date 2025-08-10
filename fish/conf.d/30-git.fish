# Git Configuration and Aliases

# Delta as git pager
set -gx GIT_PAGER delta

# Delta configuration
set -gx DELTA_FEATURES "side-by-side line-numbers decorations"
set -gx DELTA_SYNTAX_THEME "Dracula"

# Basic git aliases
alias g 'git'
alias ga 'git add'
alias gaa 'git add --all'
alias gap 'git add -p'
alias gau 'git add -u'

alias gb 'git branch'
alias gba 'git branch -a'
alias gbd 'git branch -d'
alias gbD 'git branch -D'
alias gbr 'git branch -r'

alias gc 'git commit'
alias gcm 'git commit -m'
alias gca 'git commit --amend'
alias gcam 'git commit --amend -m'
alias gcan 'git commit --amend --no-edit'
alias gcn 'git commit --no-verify'
alias gcl 'git clone'

alias gco 'git checkout'
alias gcob 'git checkout -b'
alias gcom 'git checkout main'
alias gcod 'git checkout develop'

alias gcp 'git cherry-pick'
alias gcpa 'git cherry-pick --abort'
alias gcpc 'git cherry-pick --continue'

alias gd 'git diff'
alias gds 'git diff --staged'
alias gdh 'git diff HEAD'
alias gdt 'git difftool'

alias gf 'git fetch'
alias gfa 'git fetch --all'
alias gfo 'git fetch origin'

alias gl 'git log --oneline --graph --decorate'
alias gla 'git log --oneline --graph --decorate --all'
alias glg 'git log --stat'
alias glgg 'git log --graph'
alias glgga 'git log --graph --decorate --all'
alias glo 'git log --oneline'

alias gm 'git merge'
alias gma 'git merge --abort'
alias gmc 'git merge --continue'
alias gms 'git merge --squash'

alias gp 'git push'
alias gpf 'git push --force-with-lease'
alias gpF 'git push --force'
alias gpu 'git push -u origin HEAD'
alias gpd 'git push --delete'

alias gpl 'git pull'
alias gplr 'git pull --rebase'

alias gr 'git remote'
alias gra 'git remote add'
alias grv 'git remote -v'
alias grr 'git remote remove'

alias grb 'git rebase'
alias grba 'git rebase --abort'
alias grbc 'git rebase --continue'
alias grbi 'git rebase -i'
alias grbm 'git rebase main'

alias grs 'git reset'
alias grsh 'git reset --hard'
alias grss 'git reset --soft'

alias gs 'git status'
alias gss 'git status -s'

alias gst 'git stash'
alias gsta 'git stash apply'
alias gstd 'git stash drop'
alias gstl 'git stash list'
alias gstp 'git stash pop'
alias gsts 'git stash save'
alias gstu 'git stash -u'

alias gt 'git tag'
alias gta 'git tag -a'
alias gtd 'git tag -d'

# Advanced git functions
function gclean
    git clean -fd
    git remote prune origin
end

function gpristine
    git reset --hard
    git clean -fdx
end

function gundo
    git reset --soft HEAD~1
end

function gwip
    git add -A
    git commit -m "WIP: Work in progress"
end

function gunwip
    git log -1 --oneline | grep -q "WIP" && git reset HEAD~1
end

function gquick
    git add -A
    git commit -m "$argv"
    git push
end

function gbranches
    git for-each-ref --sort=-committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'
end

function gtagged
    git log --tags --simplify-by-decoration --pretty="format:%ci %d"
end

function gfiles
    git diff --name-only $argv[1] $argv[2] 2>/dev/null || git diff --name-only $argv[1] 2>/dev/null || git diff --name-only
end

function gconflicts
    git diff --name-only --diff-filter=U
end

function gpr
    if test (count $argv) -eq 0
        gh pr create --web
    else
        gh pr create --title "$argv[1]" --body "$argv[2..-1]"
    end
end

# Git flow shortcuts
alias gfi 'git flow init'
alias gff 'git flow feature'
alias gffs 'git flow feature start'
alias gfff 'git flow feature finish'
alias gfr 'git flow release'
alias gfrs 'git flow release start'
alias gfrf 'git flow release finish'
alias gfh 'git flow hotfix'
alias gfhs 'git flow hotfix start'
alias gfhf 'git flow hotfix finish'