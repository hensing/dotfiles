# settings {{{

HISTFILE=$HOME/.zsh_history
SAVEHIST=65536
HISTSIZE=100000
DIRSTACKSIZE=10

fpath=(~/.zsh/completions $fpath)

export EDITOR=vim
export PAGER=less
export LESS=XFRaeiM # the XFR is important here: don't mess with the terminal!
export BROWSER=firefox
export EDITORX=gvim
export REPORTTIME=5     # CPU-Auslastung bei langen Jobs anzeigen:
export LC_ALL=${LC_ALL:-en_US.UTF-8}
#export LANG='de_DE.UTF-8'

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
autoload -U compinit && compinit
autoload -U keeper && keeper

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


PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/bin/vendor_perl:/usr/games:$HOME/miniconda3/bin:$HOME/miniconda2/bin"

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
        alias auu='sudo aptitude update; sudo aptitude upgrade; sudo apt-get autoremove -y'
    else
        alias as='apt-cache search'
        alias aS='apt-cache show'
        alias ai='sudo apt-get install'
        alias auu='sudo apt-get update; sudo apt-get upgrade; sudo apt-get autoremove -y'
    fi
else
    alias ls='/bin/ls -G'
    alias la='/bin/ls -AhlG'
    alias l.='/bin/ls -AhlGd .*'
    alias l='/bin/ls -hlG'
fi
alias ll="la | $PAGER"

# show files newer then 1 week or newest files if older
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

# htcondor alias
if (( $+commands[condor_status] )) ; then
    alias cs='condor_status'
    alias css='diff ~/.cs =(cs |grep -e slot.@ |cut -d " " -f1 |cut -d "@" -f2 |uniq)'
    alias cq='condor_q -dag -wide'
    alias cj='condor_q -long -attributes RemoteHost,Arguments,NumJobStarts,ImageSize,LastJobStatus,JobStatus'
    alias cver='condor_status -master -autoformat:t Name CondorVersion'
    alias crm='rm **/*.(err|out|log|pyc)'
fi


# docker alias
if (( $+commands[docker] )) ; then
    alias ds='docker ps'
    alias de='docker exec -it'
    alias dl='docker logs'
    alias di='docker inspect'
    alias dS='docker stats'
    alias dsa='docker ps -a'
    alias drm='docker rm `docker ps -q -a`'
    alias drmf='docker rm -f `docker ps -q -a`'
    alias dI='docker images'
    alias drmi='docker rmi `docker images -q`'
    alias dco='docker compose'
    alias dcp='docker compose pull'
    alias dcb='docker compose build'
    alias dcu='docker compose up'
    alias dcd='docker compose down'
fi

# git alias
if (( $+commands[git] )) ; then
    alias g='git'
    alias ga='git add'
    alias gs='git status'
    alias gl='git pull --prune'
    alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
    alias gp='git push origin HEAD'
    alias gd='git diff'
    alias gci='git commit'
    alias gca='git commit -a'
    alias gco='git checkout'
    alias gb='git branch'
    alias gs='git status -sb' # upgrade your git if -sb breaks for you. it's fun.
    alias gclean='git clean -xfd --exclude=.env --exclude=.idea'
    alias gcl='gclean --dry-run && read -q "y?Perform git clean? [y/N]" && gclean'
fi
# ipython notebook alias
if (( $+commands[jupyter] )) ; then
    alias i='jupyter console'
    alias in='jupyter notebook'
    alias inp='jupyter notebook --ip=0.0.0.0'
elif (( $+commands[ipython] )) ; then
    alias i='ipython'
    alias in='ipython notebook'
    alias inp='ipython notebook --ip=0.0.0.0'
fi

# latexdiff
ldiff() {
    latexdiff-git --pdf $1 -r `git log --abbrev-commit |head -n 1 |cut -d ' ' -f 2`
}

# eigene IP im WAN, falls hinter router
alias myip='curl checkip.dyndns.org -s | sed "s/[^0-9]*//" | fgrep . | cut -d "<" -f 1'

# }}}


# tmux completions:
if (( $+commands[tmux] )) ; then
  # completion von irgendwo im aktuellen buffer
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

  # 2011-10-19: tmux shortcut for creating/attaching named sessions
  tm() {
    [[ -z "$1" ]] && { echo "usage: tm <session>" >&2; return 1; }
    tmux has -t $1 && tmux attach -t $1 || tmux new -s $1
  }

  # 2011-10-19
  # stolen from completion function _tmux
  function __tmux-sessions() {
      local expl
      local -a sessions
      sessions=( ${${(f)"$(command tmux list-sessions)"}/:[ $'\t']##/:} )
      _describe -t sessions 'sessions' sessions "$@"
  }
  compdef __tmux-sessions tm
fi

# ssh/gpg agent via gentoo keychain:
if (( $+commands[keychain] )) ; then
    eval `keychain --eval --agents gpg,ssh --timeout 10 -q`
fi

# todo-txt
if (( $+commands[todo-txt] )) ; then
    alias t="todo-txt"
    alias tl="todo-txt ls"
    alias ta="todo-txt add"
fi


# prompt {{{

###
# See if we can use colors.

autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
fi
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
    (( count = $count + 1 ))
done

###
# %n         $USERNAME.
# @          literal '
# %m         machine name.
# %M         The full machine hostname.
# %%         #%
# %/         Present working directory ($PWD) (i. e.: /home/$USERNAME)
# %~         Present working directory ($PWD) (i. e.: ~)
# %h         Current history event number.
# %!         Current history event number.
# %L         The current value of $SHLVL.
# %S (%s)    Start (stop) standout mode.
# %U (%u)    Start (stop) underline mode.
# %B (%b)    Start (stop) boldface mode.
# %t / %@    Current time of day, in 12-hour, am/pm format.
# %T         Current time of day, in 24-hour format.
# %*         Current time of day in 24-hour  format,  with  seconds
# %N         The  name  of  the  script,  sourced file, or shell
#            function that zsh is currently executing,
# %i         The line number currently  being  executed  in  the script
# %w         The date in day-dd format.
# %W         The date in mm/dd/yy format.
# %D         The date in yy-mm-dd format.
# %D{string} string  is  formatted  using the strftime function (strftime(3))
# %l         The line (tty) the user is logged in on
# %?         The  return  code of the last command executed just before the
# prompt
# %_         The status of the parser
# %E         Clears to end of line
# %#         A  `#'  if  the shell is running with privileges, a `%' if not
# %v         The  value  of the first element of the psvar array parameter
# %{...%}    Include a string as a literal escape sequence

# SSH-string: Username@machine, wenn verbunden - ansonsten nur username
if [ $SSH_CONNECTION ]; then
    SSH_STRING="%B%n%b@%B%m%b"
else
    SSH_STRING=""
fi

# GIT PROMPT
if [[ -e ~/.zsh/git-prompt/zshrc.sh ]];
then
    setopt prompt_subst
    source ~/.zsh/git-prompt/zshrc.sh
else
    alias git_super_status=test
fi

# LINKS: (rot: Exitcode)\n PROMPT
PROMPT='%(?..$PR_RED%?\

)%{$reset_color%}%(!.%{$fg_bold[red]%}%SROOT%s%{$reset_color%}%B@%m%b.$SSH_STRING)$(git_super_status)%# '

# RECHTS:
RPROMPT="%~"    # Pfad, Befehlnr, J
# Mit Uhrzeit
#RPROMPT="%T %! %j" # Zeit, Befehlnr, J

# }}}

# farbige man-pages
export LESS_TERMCAP_mb=$'\E[00;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

#export CPLUS_INCLUDE_PATH=/sw/include
#export CPATH=/sw/include
#export LIBRARY_PATH=/sw/lib

# Completions
zstyle ':completion:*' menu yes=long-list
zstyle ':completion:*' menu select=1
# alex:
# zstyle ':completion:*' format 'completing %d'
# zstyle ':completion:*' group-name ''
zstyle ':completion:*' ignore-parents parent pwd
# zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'r:|[._-]=** r:|=**' '+m:{a-zA-Z}={A-Za-z} l:|=* r:|=*'
# zstyle ':completion:*' menu select=long-list select=0
# zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s


#load additional completion modules
zmodload -i zsh/complist

#kill completions
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' insert-ids menu
zstyle ':completion:*:*:kill:*' menu yes select=2
zstyle ':completion:*:kill:*' force-list always

##kill completion for ALL processes owned by me..
zstyle ':completion:*:kill:*:processes' command 'ps -u $USER -o pid,s,nice,stime,args'

## no flow control! (not a problem now that I know about it, but anyway.
#setopt noflowcontrol
#stty -ixon


compile=(install clean remove uninstall deinstall)
compctl -k compile make

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
  extract () {
        if [[ -f $1 ]]
        then
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

  # hosts in /etc/hosts suchen
  h() {
      grep $@ /etc/hosts
  }

  # prozess suchen
  psgrep() {
    if [ ! -z $1 ] ; then
        ps aux | grep $1 | grep -v grep
    else
        echo "!! Need name to grep for"
    fi
  }

  # prozess suchen und killen
  pskill() {
    if  [ ! -z $1 ] ; then
        kill -9 `ps ux | grep $1 | grep -v grep  | awk '{ print $2}'` 
    else
        echo "!! Need name to grep for"
    fi
  }

  # mkdir und cd
  mcd () {
    mkdir "$@" && cd "$@"
  }

  # Funktion, die bei jedem Verzeichniswechsel aufgerufen wird:
  chpwd() {
      [[ $TERM == (xterm*|*rxvt) ]] && print -Pn "\e]0;%n@%m: %~\a"
  }

  # funktion, zum wechseln in den absolutpfad des aktuellen Verzeichnisses:
  cdr() {
      cd `pwd -r`
  }

  # Funktion zum auswählen eines der letzten Verzeichnisse
  wd () {
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

  # Funktion zum auffinden fehlender parts
  rfind() {
    HEAD=$1
    START=$2
    STOP=$3
    echo "Fehlende Parts zwischen "$HEAD$START "und "$STOP ".rar"
    for i in $HEAD{$START..$STOP}; do
        if [ ! -f $i.rar ]
        then
            echo "Part "$i
        else
           continue
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
            if (( $# < 2 ))
                then echo "usage: ezdo jailname command"
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
    if  [ ! -z $1 ] ; then
        source=$1;
        target=$2;
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
#
#

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
    function zle-line-init () {
        echoti smkx
    }
    function zle-line-finish () {
        echoti rmkx
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi
bindkey '^Xs' run-with-sudo

# tmux autostart
#if [ $SSH_CONNECTION ]; then
#    if [ "$TERM[0,6]" != "screen" ]; then
#        tmux
#    fi
#fi

# python virtualenv
export WORKON_HOME=~/.virtualenvs
VIRTUALENVWRAPPER=/usr/share/virtualenvwrapper/virtualenvwrapper.sh
[ -f $VIRTUALENVWRAPPER ] && source $VIRTUALENVWRAPPER


rmpy() {
  rm **/*.(pyc|pyo|bak|tmp|egg-info)
  rm -rf **/(__pycache__|.pytest_cache|dist|build|.covorage|.ipynb_checkpoints)
}


# dircolors:
LS_COLORS='no=00;38;5;244:rs=0:di=00;38;5;33:ln=00;38;5;37:mh=00:pi=48;5;230;38;5;136;01:so=48;5;230;38;5;136;01:do=48;5;230;38;5;136;01:bd=48;5;230;38;5;244;01:cd=48;5;230;38;5;244;01:or=48;5;235;38;5;160:su=48;5;160;38;5;230:sg=48;5;136;38;5;230:ca=30;41:tw=48;5;64;38;5;230:ow=48;5;235;38;5;33:st=48;5;33;38;5;230:ex=00;38;5;64:*.tar=00;38;5;61:*.tgz=00;38;5;61:*.arj=00;38;5;61:*.taz=00;38;5;61:*.lzh=00;38;5;61:*.lzma=00;38;5;61:*.tlz=00;38;5;61:*.txz=00;38;5;61:*.zip=00;38;5;61:*.z=00;38;5;61:*.Z=00;38;5;61:*.dz=00;38;5;61:*.gz=00;38;5;61:*.lz=00;38;5;61:*.xz=00;38;5;61:*.bz2=00;38;5;61:*.bz=00;38;5;61:*.tbz=00;38;5;61:*.tbz2=00;38;5;61:*.tz=00;38;5;61:*.deb=00;38;5;61:*.rpm=00;38;5;61:*.jar=00;38;5;61:*.rar=00;38;5;61:*.ace=00;38;5;61:*.zoo=00;38;5;61:*.cpio=00;38;5;61:*.7z=00;38;5;61:*.rz=00;38;5;61:*.apk=00;38;5;61:*.gem=00;38;5;61:*.jpg=00;38;5;136:*.JPG=00;38;5;136:*.jpeg=00;38;5;136:*.gif=00;38;5;136:*.bmp=00;38;5;136:*.pbm=00;38;5;136:*.pgm=00;38;5;136:*.ppm=00;38;5;136:*.tga=00;38;5;136:*.xbm=00;38;5;136:*.xpm=00;38;5;136:*.tif=00;38;5;136:*.tiff=00;38;5;136:*.png=00;38;5;136:*.svg=00;38;5;136:*.svgz=00;38;5;136:*.mng=00;38;5;136:*.pcx=00;38;5;136:*.dl=00;38;5;136:*.xcf=00;38;5;136:*.xwd=00;38;5;136:*.yuv=00;38;5;136:*.cgm=00;38;5;136:*.emf=00;38;5;136:*.eps=00;38;5;136:*.CR2=00;38;5;136:*.ico=00;38;5;136:*.tex=00;38;5;245:*.rdf=00;38;5;245:*.owl=00;38;5;245:*.n3=00;38;5;245:*.ttl=00;38;5;245:*.nt=00;38;5;245:*.torrent=00;38;5;245:*.xml=00;38;5;245:*Makefile=00;38;5;245:*Rakefile=00;38;5;245:*build.xml=00;38;5;245:*rc=00;38;5;245:*1=00;38;5;245:*.nfo=00;38;5;245:*README=00;38;5;245:*README.txt=00;38;5;245:*readme.txt=00;38;5;245:*.md=00;38;5;245:*README.markdown=00;38;5;245:*.ini=00;38;5;245:*.yml=00;38;5;245:*.cfg=00;38;5;245:*.conf=00;38;5;245:*.c=00;38;5;245:*.cpp=00;38;5;245:*.cc=00;38;5;245:*.sqlite=00;38;5;245:*.log=00;38;5;240:*.bak=00;38;5;240:*.aux=00;38;5;240:*.lof=00;38;5;240:*.lol=00;38;5;240:*.lot=00;38;5;240:*.out=00;38;5;240:*.toc=00;38;5;240:*.bbl=00;38;5;240:*.blg=00;38;5;240:*~=00;38;5;240:*#=00;38;5;240:*.part=00;38;5;240:*.incomplete=00;38;5;240:*.swp=00;38;5;240:*.tmp=00;38;5;240:*.temp=00;38;5;240:*.o=00;38;5;240:*.pyc=00;38;5;240:*.class=00;38;5;240:*.cache=00;38;5;240:*.aac=00;38;5;166:*.au=00;38;5;166:*.flac=00;38;5;166:*.mid=00;38;5;166:*.midi=00;38;5;166:*.mka=00;38;5;166:*.mp3=00;38;5;166:*.mpc=00;38;5;166:*.ogg=00;38;5;166:*.ra=00;38;5;166:*.wav=00;38;5;166:*.m4a=00;38;5;166:*.axa=00;38;5;166:*.oga=00;38;5;166:*.spx=00;38;5;166:*.xspf=00;38;5;166:*.mov=00;38;5;166:*.mpg=00;38;5;166:*.mpeg=00;38;5;166:*.m2v=00;38;5;166:*.mkv=00;38;5;166:*.ogm=00;38;5;166:*.mp4=00;38;5;166:*.m4v=00;38;5;166:*.mp4v=00;38;5;166:*.vob=00;38;5;166:*.qt=00;38;5;166:*.nuv=00;38;5;166:*.wmv=00;38;5;166:*.asf=00;38;5;166:*.rm=00;38;5;166:*.rmvb=00;38;5;166:*.flc=00;38;5;166:*.avi=00;38;5;166:*.fli=00;38;5;166:*.flv=00;38;5;166:*.gl=00;38;5;166:*.m2ts=00;38;5;166:*.divx=00;38;5;166:*.webm=00;38;5;166:*.axv=00;38;5;166:*.anx=00;38;5;166:*.ogv=00;38;5;166:*.ogx=00;38;5;166:';
export LS_COLORS

## notify by ntfy (https://github.com/dschep/nfty)
#if (( $+commands[ntfy] )); then
	#eval "$(ntfy shell-integration -s zsh -L 300 -f)"
	#export AUTO_NTFY_DONE_IGNORE="vim screen tmux ipython in inp ssh pm-suspend"
#fi

### Docker volumes backup and restore
#
# Function to export a Docker Volume to a .tar file
# Usage: docker_volume_export <volume_name> <target_tar_path>
function docker_volume_export {
  set -e # Exit immediately if a command exits with a non-zero status
  local volume_name="$1"
  local target_tar_path="$2"

  if [[ -z "$volume_name" || -z "$target_tar_path" ]]; then
    print "Usage: docker_volume_export <volume_name> <target_tar_path>"
    return 1
  fi

  print "📦 Exporting Docker Volume '$volume_name' to '$target_tar_path'..."

  # Optional: Check if the volume exists (docker run will fail anyway)
  # if ! sudo docker volume inspect "$volume_name" > /dev/null 2>&1; then
  #   print "❌ Error: Volume '$volume_name' does not exist."
  #   return 1
  # fi

  # Ensure the target directory exists
  local target_dir="$(dirname "$target_tar_path")"
  if [[ ! -d "$target_dir" ]]; then
      print "📁 Creating target directory '$target_dir'..."
      mkdir -p "$target_dir"
  fi

  # Start a temporary container and archive the volume to tar
  # Using alpine as it's small and includes tar
  if sudo docker run --rm -v "$volume_name":/volume_data alpine tar -cvf - -C /volume_data . > "$target_tar_path"; then
    print "✅ Export successful."
    return 0
  else
    print "❌ Export failed."
    return 1
  fi
}

# Function to import a .tar file into a Docker Volume
# Usage: docker_volume_import <source_tar_path> <target_volume_name>
function docker_volume_import {
  #set -e # Exit immediately if a command exits with a non-zero status
  local source_tar_path="$1"
  local target_volume_name="$2"

  if [[ -z "$source_tar_path" || -z "$target_volume_name" ]]; then
    print "Usage: docker_volume_import <source_tar_path> <target_volume_name>"
    return 1
  fi

  if [[ ! -f "$source_tar_path" ]]; then
    print "❌ Error: Source tar file '$source_tar_path' not found."
    return 1
  fi

  print "📦 Importing '$source_tar_path' into Docker Volume '$target_volume_name'..."

  # Check if the target volume exists. If not, create it.
  if ! sudo docker volume inspect "$target_volume_name" > /dev/null 2>&1; then
    print "ℹ️ Volume '$target_volume_name' not found, creating it..."
    if ! sudo docker volume create "$target_volume_name"; then
        print "❌ Error creating volume '$target_volume_name'."
        return 1
    fi
  fi

  # Start a temporary container, mount the volume, and extract the tar
  # The tar file content is piped to the container's stdin
  # Using alpine as it's small and includes tar
  if cat "$source_tar_path" | sudo docker run --rm -i -v "$target_volume_name":/volume_data alpine tar -xvf - -C /volume_data; then
     print "✅ Import successful."
     return 0
  else
     print "❌ Import failed."
     return 1
  fi
}

# Function to migrate data from a host directory (bind mount source) to a Docker Volume
# Usage: docker_bind_to_volume <source_host_directory> <target_volume_name>
function docker_bind_to_volume {
  #set -e # Exit immediately if a command exits with a non-zero status
  local source_host_dir="$1"
  local target_volume_name="$2"

  if [[ -z "$source_host_dir" || -z "$target_volume_name" ]]; then
    print "Usage: docker_bind_to_volume <source_host_directory> <target_volume_name>"
    return 1
  fi

  if [[ ! -d "$source_host_dir" ]]; then
    print "❌ Error: Source host directory '$source_host_dir' not found or is not a directory."
    return 1
  fi

  print "📦 Migrating data from host directory '$source_host_dir' to Docker Volume '$target_volume_name' using rsync..."

  # Check if the target volume exists. If not, create it.
  if ! sudo docker volume inspect "$target_volume_name" > /dev/null 2>&1; then
    print "ℹ️ Volume '$target_volume_name' not found, creating it..."
    if ! sudo docker volume create "$target_volume_name"; then
        print "❌ Error creating volume '$target_volume_name'."
        return 1
    fi
  fi

  # Start a temporary container, mount the source directory and the target volume, and copy data using rsync
  # Using ubuntu as it includes rsync by default
  print "⏳ Copying data with rsync... This may take a while for large directories."
  # rsync requires source and destination paths. -a is for archive mode (permissions, recursive etc.)
  # A trailing slash on the source (/src_data/) copies the *contents*
  if sudo docker run --rm \
     -v "$source_host_dir":/src_data \
     -v "$target_volume_name":/dest_data \
     ubuntu bash -c "rsync -a /src_data/ /dest_data/ && sync" > /dev/null; then # Use rsync -avz for verbose, archive, compress
    print "✅ Migration successful."
    return 0
  else
    print "❌ Migration failed during rsync copy."
    return 1
  fi
}

# check which docker-container is running as root and check for docker.sock mount
docker_check_root () {
    echo "--- Docker Container Security Check ---"

    # Iterate over all running container IDs
    for container_id in $(docker ps -q)
    do
        # Get container name, removing the leading slash
        container_name=$(docker inspect --format '{{.Name}}' "$container_id" | sed 's/\///')
        STATUS_ICON="✅"
        DOCKER_SOCK_MOUNTED=false # Flag for later output

        # 1. Check for mounted docker.sock and set the flag/icon
        if docker inspect "$container_id" --format '{{json .Mounts}}' | grep -q '/var/run/docker.sock'
        then
            STATUS_ICON="⚠️"
            DOCKER_SOCK_MOUNTED=true
        fi

        # 2. Get the main process UID from the container's perspective
        container_id_full=$(docker exec "$container_id" id 2>/dev/null)
        # Extract only the numerical UID to compare against 0
        container_uid=$(echo "$container_id_full" | grep -oP 'uid=\K\d+')

        # 3. Check for Root processes from the Host's perspective (crucial for security)
        # Use 'eouid,pid,cmd' for maximum detail and to satisfy Docker's requirements.
        # We look for the numerical Host UID '0' and print all fields ($0).
        HOST_ROOT_PIDS=$(docker top "$container_id" -eo uid,pid,cmd 2>/dev/null | awk '$1 == "0" && $1 != "UID" { print $0 }')

        # Upgrade status icon if any Root processes were found
        if [[ -n "$HOST_ROOT_PIDS" ]]; then
            STATUS_ICON="⚠️"
        fi

        # 4. Format the primary output line

        # A: 'id' tool is missing in the container
        if [[ -z "$container_uid" ]]; then
            echo "⚠️ Container $container_name (${container_id:0:12}) runs as: UNDETERMINED (id tool missing)"

        # B: Main process inside the container is Root (Container UID = 0)
        elif [[ "$container_uid" -eq 0 ]]; then
            echo "⚠️ Container $container_name (${container_id:0:12}) runs as: ROOT (UID 0)!"

        # C: Main process inside the container is Non-Root
        else
            echo "$STATUS_ICON Container $container_name (${container_id:0:12}) runs as: $container_id_full"
        fi

        # 5. Detailed Security Warnings (Docker Socket and Root Processes)

        # Highlight Docker Socket mounting
        if [[ "$DOCKER_SOCK_MOUNTED" == true ]]; then
            echo "   -> 🚨 DOCKER_SOCK MOUNTED! (Can grant Host Root access)"
        fi

        # Highlight Root processes running on the Host
        if [[ -n "$HOST_ROOT_PIDS" ]]; then
            echo "   -> 🚨 The following processes are running as HOST ROOT (UID/PID/CMD):"
            # Indent the list of processes
            echo "$HOST_ROOT_PIDS" | sed 's/^/      * /'
        fi

        echo
    done
    echo "--- End of Check ---"
}
