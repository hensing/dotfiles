# settings {{{

HISTFILE=$HOME/.zsh_history
SAVEHIST=65536
HISTSIZE=100000
DIRSTACKSIZE=10

export EDITOR=vim
export PAGER=less
export LESS=XFRaeiM # the XFR is important here: don't mess with the terminal!
export BROWSER=firefox
export EDITORX=gvim
export REPORTTIME=5     # CPU-Auslastung bei langen Jobs anzeigen:
export LC_ALL=${LC_ALL:-en_US.UTF-8}

bindkey -v   # vim keybindings

# Automatisch nach 5 min ausloggen, wenn root
if [[ $USER == root ]]; then
    TMOUT=300
fi

# }}}

# options {{{

autoload -U colors && colors    # Modul für farbigen Prompt
autoload zmv
autoload regex
autoload -Uz merge_gpx
autoload -Uz add-zsh-hook

#setopt auto_cd              # change to dir without using cd
setopt auto_pushd           # push old dir on dir stack
unset MAILCHECK             # no MailChecks
setopt complete_in_word     # don't jump to end of word on [TAB]
#setopt rm_star_wait         # waits on rm *
setopt correct              # tries to correct the spelling
setopt glob_dots            # no leading . for explicit matching
setopt extended_glob        #
setopt share_history        # share history between multiply running zsh
setopt extended_history     # safe time and length of execution
setopt hist_ignore_all_dups # don't save duplicates
setopt hist_no_store        # don't store hist and fc commands
setopt hist_reduce_blanks   #
setopt append_history       # append history, don't overwrite
setopt hist_ignore_space    # don't save lines with blank as first charakter, good for clear passwds
setopt notify               # report on background job status immediately
setopt check_jobs           # report on job status when leaving zsh
setopt long_list_jobs       #
setopt cdable_vars          # try to extend args to cd
setopt prompt_subst         # needed for colored prompt
setopt nobeep               # no beeping, honking, whistling...

# }}}

PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/opt/homebrew/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/bin/vendor_perl:/usr/games:$HOME/miniconda3/bin"

# fpath — before compinit
fpath=(~/.zsh/completions ~/.zsh/functions $fpath)
[[ $OSTYPE == darwin* ]] && fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
autoload -U compinit && compinit

# alias {{{
# pass sudo to alias
alias sudo='nocorrect sudo '

# unify ls commands
if [[ $OSTYPE == linux* ]]; then
    alias ls='/bin/ls --color'
    alias la='/bin/ls -Ahl --color'
    alias l.='/bin/ls -Ahld --color .*'
    alias l='/bin/ls -hl --color'
    if (( $+commands[aptitude] )); then
        alias as='aptitude search'
        alias aS='aptitude show'
        alias ai='sudo aptitude install'
        alias auu='sudo aptitude update; sudo aptitude upgrade; sudo apt autoremove -y'
    else
        alias as='apt-cache search'
        alias aS='apt-cache show'
        alias ai='sudo apt install'
        alias auu='sudo apt update; sudo apt upgrade; sudo apt autoremove -y'
    fi
else
    alias ls='/bin/ls -G'
    alias la='/bin/ls -AhlG'
    alias l.='/bin/ls -AhlGd .*'
    alias l='/bin/ls -hlG'
fi
alias ll="la | $PAGER"

# show files newer than 1 week or newest files if older
alias lsnew='/bin/ls -ahlt *(.mw-1) || ls -ahlt | head'
# show old files
alias lsold='/bin/ls -ahlt *(.)| tail'

alias ..='cd ..'
alias ...='cd ../..'

alias grep='grep --color=auto'

# cat non-empty log / err / out
alias logcat="$PAGER *.log(L+0)"
alias errcat="$PAGER *.err(L+0)"
alias outcat="$PAGER *.out(L+0)"

alias z='vim ~/.zshrc'
alias v='vim ~/.vimrc'
if (( $+commands[nvim] )); then
    alias vim='nvim'
    export EDITOR=nvim
fi

alias mmv='noglob zmv -W'
alias zln='zmv -L'
alias zcp='zmv -C'

alias j='jobs -l'
alias up='echo " `uptime -p` since `uptime -s`\n"'

# eigene IP im WAN, falls hinter router
alias myip='curl checkip.dyndns.org -s | sed "s/[^0-9]*//" | fgrep . | cut -d "<" -f 1'

# ssh/gpg agent via gentoo keychain
if (( $+commands[keychain] )); then
    eval `keychain --eval --agents gpg,ssh --timeout 10 -q`
fi

# todo-txt
if (( $+commands[todo-txt] )); then
    alias t="todo-txt"
    alias tl="todo-txt ls"
    alias ta="todo-txt add"
fi

# }}}


# prompt {{{

autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
fi
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
    (( count = $count + 1 ))
done

# SSH-string: Username@machine, wenn verbunden - ansonsten nur username
if [ $SSH_CONNECTION ]; then
    SSH_STRING="%B%n%b@%B%m%b"
else
    SSH_STRING=""
fi

# GIT PROMPT
if [[ -e ~/.zsh/git-prompt/zshrc.sh ]]; then
    setopt prompt_subst
    source ~/.zsh/git-prompt/zshrc.sh
else
    alias git_super_status=test
fi

# LINKS: (rot: Exitcode)\n PROMPT
PROMPT='%(?..$PR_RED%?

)%{$reset_color%}%(!.%{$fg_bold[red]%}%SROOT%s%{$reset_color%}%B@%m%b.$SSH_STRING)$(git_super_status)%# '

# RECHTS:
RPROMPT="%~"

# }}}

# farbige man-pages
export LESS_TERMCAP_mb=$'\E[00;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Completions {{{

zstyle ':completion:*' menu yes=long-list
zstyle ':completion:*' menu select=1
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'r:|[._-]=** r:|=**' '+m:{a-zA-Z}={A-Za-z} l:|=* r:|=*'

zmodload -i zsh/complist

# kill completions
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' insert-ids menu
zstyle ':completion:*:*:kill:*' menu yes select=2
zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*:kill:*:processes' command 'ps -u $USER -o pid,s,nice,stime,args'

compile=(install clean remove uninstall deinstall)
compctl -k compile make

# }}}

# Terminal-Modi
if [ "$TERM" != "screen-256color" ]; then
    export TERM=xterm-256color
fi

# Funktionen {{{

# Description: Run command as sudo
run-with-sudo() { LBUFFER="sudo $LBUFFER" }
zle -N run-with-sudo

# get GPP keys for apt
function get_apt_key() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: get_apt_key <key-id> <repo-name>"
    return 1
  fi

  local KEY_ID="$1"
  local REPO_NAME="$2"
  local KEY_PATH="/usr/share/keyrings/${REPO_NAME}.gpg"

  echo "Fetching key ${KEY_ID} for ${REPO_NAME}..."
  sudo gpg --no-default-keyring --keyring "${KEY_PATH}" --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "${KEY_ID}"

  if [ $? -eq 0 ]; then
    echo "Key successfully imported to ${KEY_PATH}."
  else
    echo "Error: Failed to import key."
    return 1
  fi
}

# Usage: extract <file>
# Description: extracts archived files (maybe)
extract() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2)  bzip2 -v -d $1      ;;
            *.tar.gz)   tar -xvzf $1        ;;
            *.rar)      unrar e $1          ;;
            *.deb)      ar -x $1            ;;
            *.bz2)      bzip2 -d $1         ;;
            *.lzh)      lha x $1            ;;
            *.gz)       gunzip -d $1        ;;
            *.tar)      tar -xvf $1         ;;
            *.tgz)      tar -xvzf $1        ;;
            *.tbz2)     tar -jxvf $1        ;;
            *.zip)      unzip $1            ;;
            *.Z)        uncompress $1       ;;
            *)          echo "'$1' Error. Please go away" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# tex-müll entfernen
# (N): null glob
rmtex() {
    rm **/*.(nav|snm|log|aux|out|toc|bbl|blg|dvi|synctex.gz|pdfsync|alg|acr|acn|bcf|glg|gls|glo|slg|syi|syg|ist|nlo|*~|fdb_latexmk|fls|run.xml) **/*-blx.bib(N)
}

# python-müll entfernen
rmpy() {
    rm **/*.(pyc|pyo|bak|tmp|egg-info)
    rm -rf **/(__pycache__|.pytest_cache|dist|build|.coverage|.ipynb_checkpoints)
}

# hosts in /etc/hosts suchen
h() {
    grep $@ /etc/hosts
}

# prozess suchen
psgrep() {
    if [ ! -z $1 ]; then
        ps aux | grep $1 | grep -v grep
    else
        echo "!! Need name to grep for"
    fi
}

# prozess suchen und killen
pskill() {
    if [ ! -z $1 ]; then
        kill -9 `ps ux | grep $1 | grep -v grep | awk '{ print $2}'`
    else
        echo "!! Need name to grep for"
    fi
}

# mkdir und cd
mcd() {
    mkdir "$@" && cd "$@"
}

# Terminal-Titel bei Verzeichniswechsel setzen (parallel zum git-prompt-Hook)
_set_terminal_title() {
    [[ $TERM == (xterm*|*rxvt) ]] && print -Pn "\e]0;%n@%m: %~\a"
}
add-zsh-hook chpwd _set_terminal_title

# funktion, zum wechseln in den absolutpfad des aktuellen Verzeichnisses
cdr() {
    cd `pwd -r`
}

# Funktion zum auswählen eines der letzten Verzeichnisse
wd() {
    print "Liste der letzten besuchten Verzeichnisse:"
    dirs -v
    print -n "cd wohin? "
    read WOHIN
    cd +${WOHIN:=0}
}

# zd: fast directory switching via https://github.com/rupa/z
if [[ -e ~/.zsh/z/z.sh ]]; then
    export _Z_CMD=zd
    . ~/.zsh/z/z.sh
fi

# Funktion zum auffinden fehlender .rar-Parts
rfind() {
    HEAD=$1
    START=$2
    STOP=$3
    echo "Fehlende Parts zwischen "$HEAD$START "und "$STOP ".rar"
    for i in $HEAD{$START..$STOP}; do
        if [ ! -f $i.rar ]; then
            echo "Part "$i
        fi
    done
    echo "Parts, die kleiner als 1MB sind:"
    find . -size -1M -type f
}

# Funktion zum konvertieren nach utf-8
conv2utf8() {
    if [[ $OSTYPE == linux* ]]; then
        ENCIN=`file $@ -i | awk '{print $3}' | sed 's/charset=//g'`
    else
        ENCIN=`file $@ -I | awk '{print $3}' | sed 's/charset=//g'`
    fi

    ENCOUT='utf-8'
    SUFFIXIN=${@##*.}
    PREFIXIN=${@%.*}
    OUT=$PREFIXIN"_utf8."$SUFFIXIN

    print "Konvertiere $@ von $ENCIN nach $ENCOUT ..."
    iconv -f $ENCIN -t $ENCOUT $@ > $OUT
}

# Funktion zum starten von ssh mit Schreibzugriff auf die .ssh/known_hosts
SSH() {
    chmod 660 ~/.ssh/known_hosts
    ssh $@
    chmod 440 ~/.ssh/known_hosts
}

# ezjail do: executes a command in jail via ezjail
if (( $+commands[ezjail-admin] )); then
    ezdo() {
        if (( $# < 2 )); then
            echo "usage: ezdo jailname command"
        else
            JAIL=${argv[1]}
            COMMAND=${argv[2, -1]}
            print "executing '$COMMAND' in jail '$JAIL'"
            sudo ezjail-admin console -e "$COMMAND" $JAIL
        fi
    }
fi

# Funktion für mv --parent
pmv() {
    if [ ! -z $1 ]; then
        source=$1
        target=$2
        mkdir -p "$target"/"$(dirname $source)"
        mv "$source" "$target"/"$(dirname $source)"/
    else
        print "simulates 'mv --parent'"
        print "usage: pmv /path/to/source path/to/target"
    fi
}

# list all manually installed packages
dump_installed() {
    if (( $+commands[aptitude] )); then
        comm -23 <(aptitude search '~i !~M' -F '%p' | sed "s/ *$//" | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)
    else
        comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)
    fi
}

# }}}


# set key bindings via terminfo
# via http://zshwiki.org/home/zle/bindkey
zmodload zsh/terminfo
typeset -A key

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      history-beginning-search-backward
[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    history-beginning-search-forward
[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init()   { echoti smkx }
    function zle-line-finish() { echoti rmkx }
    zle -N zle-line-init
    zle -N zle-line-finish
fi
bindkey '^Xs' run-with-sudo

# dircolors:
LS_COLORS='no=00;38;5;244:rs=0:di=00;38;5;33:ln=00;38;5;37:mh=00:pi=48;5;230;38;5;136;01:so=48;5;230;38;5;136;01:do=48;5;230;38;5;136;01:bd=48;5;230;38;5;244;01:cd=48;5;230;38;5;244;01:or=48;5;235;38;5;160:su=48;5;160;38;5;230:sg=48;5;136;38;5;230:ca=30;41:tw=48;5;64;38;5;230:ow=48;5;235;38;5;33:st=48;5;33;38;5;230:ex=00;38;5;64:*.tar=00;38;5;61:*.tgz=00;38;5;61:*.arj=00;38;5;61:*.taz=00;38;5;61:*.lzh=00;38;5;61:*.lzma=00;38;5;61:*.tlz=00;38;5;61:*.txz=00;38;5;61:*.zip=00;38;5;61:*.z=00;38;5;61:*.Z=00;38;5;61:*.dz=00;38;5;61:*.gz=00;38;5;61:*.lz=00;38;5;61:*.xz=00;38;5;61:*.bz2=00;38;5;61:*.bz=00;38;5;61:*.tbz=00;38;5;61:*.tbz2=00;38;5;61:*.tz=00;38;5;61:*.deb=00;38;5;61:*.rpm=00;38;5;61:*.jar=00;38;5;61:*.rar=00;38;5;61:*.ace=00;38;5;61:*.zoo=00;38;5;61:*.cpio=00;38;5;61:*.7z=00;38;5;61:*.rz=00;38;5;61:*.apk=00;38;5;61:*.gem=00;38;5;61:*.jpg=00;38;5;136:*.JPG=00;38;5;136:*.jpeg=00;38;5;136:*.gif=00;38;5;136:*.bmp=00;38;5;136:*.pbm=00;38;5;136:*.pgm=00;38;5;136:*.ppm=00;38;5;136:*.tga=00;38;5;136:*.xbm=00;38;5;136:*.xpm=00;38;5;136:*.tif=00;38;5;136:*.tiff=00;38;5;136:*.png=00;38;5;136:*.svg=00;38;5;136:*.svgz=00;38;5;136:*.mng=00;38;5;136:*.pcx=00;38;5;136:*.dl=00;38;5;136:*.xcf=00;38;5;136:*.xwd=00;38;5;136:*.yuv=00;38;5;136:*.cgm=00;38;5;136:*.emf=00;38;5;136:*.eps=00;38;5;136:*.CR2=00;38;5;136:*.ico=00;38;5;136:*.tex=00;38;5;245:*.rdf=00;38;5;245:*.owl=00;38;5;245:*.n3=00;38;5;245:*.ttl=00;38;5;245:*.nt=00;38;5;245:*.torrent=00;38;5;245:*.xml=00;38;5;245:*Makefile=00;38;5;245:*Rakefile=00;38;5;245:*build.xml=00;38;5;245:*rc=00;38;5;245:*1=00;38;5;245:*.nfo=00;38;5;245:*README=00;38;5;245:*README.txt=00;38;5;245:*readme.txt=00;38;5;245:*.md=00;38;5;245:*README.markdown=00;38;5;245:*.ini=00;38;5;245:*.yml=00;38;5;245:*.cfg=00;38;5;245:*.conf=00;38;5;245:*.c=00;38;5;245:*.cpp=00;38;5;245:*.cc=00;38;5;245:*.sqlite=00;38;5;245:*.log=00;38;5;240:*.bak=00;38;5;240:*.aux=00;38;5;240:*.lof=00;38;5;240:*.lol=00;38;5;240:*.lot=00;38;5;240:*.out=00;38;5;240:*.toc=00;38;5;240:*.bbl=00;38;5;240:*.blg=00;38;5;240:*~=00;38;5;240:*#=00;38;5;240:*.part=00;38;5;240:*.incomplete=00;38;5;240:*.swp=00;38;5;240:*.tmp=00;38;5;240:*.temp=00;38;5;240:*.o=00;38;5;240:*.pyc=00;38;5;240:*.class=00;38;5;240:*.cache=00;38;5;240:*.aac=00;38;5;166:*.au=00;38;5;166:*.flac=00;38;5;166:*.mid=00;38;5;166:*.midi=00;38;5;166:*.mka=00;38;5;166:*.mp3=00;38;5;166:*.mpc=00;38;5;166:*.ogg=00;38;5;166:*.ra=00;38;5;166:*.wav=00;38;5;166:*.m4a=00;38;5;166:*.axa=00;38;5;166:*.oga=00;38;5;166:*.spx=00;38;5;166:*.xspf=00;38;5;166:*.mov=00;38;5;166:*.mpg=00;38;5;166:*.mpeg=00;38;5;166:*.m2v=00;38;5;166:*.mkv=00;38;5;166:*.ogm=00;38;5;166:*.mp4=00;38;5;166:*.m4v=00;38;5;166:*.mp4v=00;38;5;166:*.vob=00;38;5;166:*.qt=00;38;5;166:*.nuv=00;38;5;166:*.wmv=00;38;5;166:*.asf=00;38;5;166:*.rm=00;38;5;166:*.rmvb=00;38;5;166:*.flc=00;38;5;166:*.avi=00;38;5;166:*.fli=00;38;5;166:*.flv=00;38;5;166:*.gl=00;38;5;166:*.m2ts=00;38;5;166:*.divx=00;38;5;166:*.webm=00;38;5;166:*.axv=00;38;5;166:*.anx=00;38;5;166:*.ogv=00;38;5;166:*.ogx=00;38;5;166:'
export LS_COLORS

# --- modules ---
for _m in condor docker git jupyter tmux python borgmatic; do
    [[ -f ~/.zsh/${_m}.zsh ]] && source ~/.zsh/${_m}.zsh
done
unset _m
