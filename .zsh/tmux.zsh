# tmux completions and helpers — loaded only when tmux is present
if (( $+commands[tmux] )); then

    # Complete words from current tmux pane buffer
    _tmux_pane_words() {
        local expl
        local -a w
        if [[ -z "$TMUX_PANE" ]]; then
            _message "not running inside tmux!"
            return 1
        fi
        w=( ${(u)=$(tmux capture-pane \; show-buffer \; delete-buffer)} )
        _wanted values expl 'words from current tmux pane' compadd -a w
    }

    zle -C tmux-pane-words-prefix   complete-word _generic
    zle -C tmux-pane-words-anywhere complete-word _generic
    bindkey '^Xt' tmux-pane-words-prefix
    bindkey '^X^X' tmux-pane-words-anywhere
    zstyle ':completion:tmux-pane-words-(prefix|anywhere):*' completer _tmux_pane_words
    zstyle ':completion:tmux-pane-words-(prefix|anywhere):*' ignore-line current
    zstyle ':completion:tmux-pane-words-anywhere:*' matcher-list 'b:=* m:{A-Za-z}={a-zA-Z}'

    # Create or attach to a named session
    tm() {
        [[ -z "$1" ]] && { echo "usage: tm <session>" >&2; return 1; }
        tmux has -t $1 && tmux attach -t $1 || tmux new -s $1
    }

    function __tmux-sessions() {
        local expl
        local -a sessions
        sessions=( ${${(f)"$(command tmux list-sessions)"}/:[ $'\t']##/:} )
        _describe -t sessions 'sessions' sessions "$@"
    }
    compdef __tmux-sessions tm

fi
