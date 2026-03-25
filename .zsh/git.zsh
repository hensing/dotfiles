# Git aliases and functions — loaded only when git is present
if (( $+commands[git] )); then
    alias g='git'
    alias ga='git add'
    alias gs='git status -sb'
    alias gl='git pull --prune'
    alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
    alias gp='git push origin HEAD'
    alias gd='git diff'
    alias gci='git commit'
    alias gca='git commit -a'
    alias gco='git checkout'
    alias gb='git branch'
    alias gclean='git clean -xfd --exclude=.env --exclude=.idea'
    alias gcl='gclean --dry-run && read -q "y?Perform git clean? [y/N]" && gclean'

    ldiff() {
        latexdiff-git --pdf $1 -r `git log --abbrev-commit |head -n 1 |cut -d ' ' -f 2`
    }
fi
