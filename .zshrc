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


if [[ $OSTYPE == linux-gnu ]]; then
    PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/games:$HOME/miniconda2/bin"
else
    PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:$HOME/miniconda2/bin"
fi

# alias {{{
# bsd und gnu ls fressen verschiedene optionen *kotz* 
if [[ $OSTYPE == linux-gnu ]]; then
    alias ls='/bin/ls --color'
    alias la='/bin/ls -Ahl --color'
    alias l.='/bin/ls -Ahld --color .*'
    alias l='/bin/ls -hl --color'
    alias ak='sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys'
    if (( $+commands[aptitude] )); then
        alias as='aptitude search'
        alias aS='aptitude show'
        alias ai='sudo aptitude install'
        alias auu='sudo aptitude update; sudo aptitude upgrade'
    else
        alias as='apt-cache search'
        alias as='apt-cache show'
        alias ai='sudo apt-get install'
        alias auu='sudo apt-get update; sudo apt-get upgrade'
    fi
else
    alias ls='/bin/ls -G'
    alias la='/bin/ls -AhlG'
    alias l.='/bin/ls -AhlGd .*'
    alias l='/bin/ls -hlG'
fi
alias ll="la | $PAGER"

alias lsnew='/bin/ls -ahlt *(mw-1) | head'
alias lsold='/bin/ls -ahlt | tail'

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
fi

alias mmv='noglob zmv -W'
alias zln='zmv -L'
alias zcp='zmv -C'

alias j='jobs -l'

# htcondor alias
if (( $+commands[condor_status] )) ; then
    alias cs='condor_status'
    alias css='diff ~/.cs =(cs |grep -e slot.@ |cut -d " " -f1 |cut -d "@" -f2 |uniq)'
    alias cq='condor_q -dag -wide'
    alias cj='condor_q -long -attributes RemoteHost,Arguments,NumJobStarts,ImageSize,LastJobStatus,JobStatus'
    alias cver='condor_status -master -autoformat:t Name CondorVersion'
    alias crm='rm **/*.(err|out|log|pyc)'
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
fi

# eigene IP im WAN, falls hinter router
alias myip='curl checkip.dyndns.org -s | sed "s/[^0-9]*//" | fgrep . | cut -d "<" -f 1'

# aticonfig alias
alias ati='aticonfig --od-gettemperature --od-getclocks --adapter=all'
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
  rmtex() {
      rm **/*.(nav|snm|log|aux|out|toc|bbl|blg|dvi|synctex.gz|pdfsync|alg|acr|acn|glg|gls|glo|slg|syi|syg|ist|nlo|*~|fdb_latexmk|fls|run.xml) **/*-blx.bib
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
      if [[ $OSTYPE == linux-gnu ]]; then
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

# }}}
#
#

if [[ $OSTYPE == linux-gnu ]]; then
    LD_LIBRARY_PATH=/opt/AMDAPP/lib/x86_64:$LD_LIBRARY_PATH
fi

# holy pos1→end-fix:
source ~/.zkbd/zkbd_function
#autoload zkbd
function zkbd_file() {
    local termID=${OSTYPE//[0-9.]/}
    [[ -f ~/.zkbd/${TERM}-${termID} ]] && printf '%s' ~/".zkbd/${TERM}-${termID}" && return 0
    return 1
}

[[ ! -d ~/.zkbd ]] && mkdir ~/.zkbd
keyfile=$(zkbd_file)
ret=$?
if [[ ${ret} -ne 0 ]]; then
    zkbd
    keyfile=$(zkbd_file)
    ret=$?
fi
if [[ ${ret} -eq 0 ]] ; then
    source "${keyfile}"
else
    printf 'Failed to setup keys using zkbd.\n'
fi
unfunction zkbd_file; unset keyfile ret

# setup key accordingly
[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      history-beginning-search-backward
[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    history-beginning-search-forward
[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char


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

# dircolors:
LS_COLORS='no=00;38;5;244:rs=0:di=00;38;5;33:ln=00;38;5;37:mh=00:pi=48;5;230;38;5;136;01:so=48;5;230;38;5;136;01:do=48;5;230;38;5;136;01:bd=48;5;230;38;5;244;01:cd=48;5;230;38;5;244;01:or=48;5;235;38;5;160:su=48;5;160;38;5;230:sg=48;5;136;38;5;230:ca=30;41:tw=48;5;64;38;5;230:ow=48;5;235;38;5;33:st=48;5;33;38;5;230:ex=00;38;5;64:*.tar=00;38;5;61:*.tgz=00;38;5;61:*.arj=00;38;5;61:*.taz=00;38;5;61:*.lzh=00;38;5;61:*.lzma=00;38;5;61:*.tlz=00;38;5;61:*.txz=00;38;5;61:*.zip=00;38;5;61:*.z=00;38;5;61:*.Z=00;38;5;61:*.dz=00;38;5;61:*.gz=00;38;5;61:*.lz=00;38;5;61:*.xz=00;38;5;61:*.bz2=00;38;5;61:*.bz=00;38;5;61:*.tbz=00;38;5;61:*.tbz2=00;38;5;61:*.tz=00;38;5;61:*.deb=00;38;5;61:*.rpm=00;38;5;61:*.jar=00;38;5;61:*.rar=00;38;5;61:*.ace=00;38;5;61:*.zoo=00;38;5;61:*.cpio=00;38;5;61:*.7z=00;38;5;61:*.rz=00;38;5;61:*.apk=00;38;5;61:*.gem=00;38;5;61:*.jpg=00;38;5;136:*.JPG=00;38;5;136:*.jpeg=00;38;5;136:*.gif=00;38;5;136:*.bmp=00;38;5;136:*.pbm=00;38;5;136:*.pgm=00;38;5;136:*.ppm=00;38;5;136:*.tga=00;38;5;136:*.xbm=00;38;5;136:*.xpm=00;38;5;136:*.tif=00;38;5;136:*.tiff=00;38;5;136:*.png=00;38;5;136:*.svg=00;38;5;136:*.svgz=00;38;5;136:*.mng=00;38;5;136:*.pcx=00;38;5;136:*.dl=00;38;5;136:*.xcf=00;38;5;136:*.xwd=00;38;5;136:*.yuv=00;38;5;136:*.cgm=00;38;5;136:*.emf=00;38;5;136:*.eps=00;38;5;136:*.CR2=00;38;5;136:*.ico=00;38;5;136:*.tex=00;38;5;245:*.rdf=00;38;5;245:*.owl=00;38;5;245:*.n3=00;38;5;245:*.ttl=00;38;5;245:*.nt=00;38;5;245:*.torrent=00;38;5;245:*.xml=00;38;5;245:*Makefile=00;38;5;245:*Rakefile=00;38;5;245:*build.xml=00;38;5;245:*rc=00;38;5;245:*1=00;38;5;245:*.nfo=00;38;5;245:*README=00;38;5;245:*README.txt=00;38;5;245:*readme.txt=00;38;5;245:*.md=00;38;5;245:*README.markdown=00;38;5;245:*.ini=00;38;5;245:*.yml=00;38;5;245:*.cfg=00;38;5;245:*.conf=00;38;5;245:*.c=00;38;5;245:*.cpp=00;38;5;245:*.cc=00;38;5;245:*.sqlite=00;38;5;245:*.log=00;38;5;240:*.bak=00;38;5;240:*.aux=00;38;5;240:*.lof=00;38;5;240:*.lol=00;38;5;240:*.lot=00;38;5;240:*.out=00;38;5;240:*.toc=00;38;5;240:*.bbl=00;38;5;240:*.blg=00;38;5;240:*~=00;38;5;240:*#=00;38;5;240:*.part=00;38;5;240:*.incomplete=00;38;5;240:*.swp=00;38;5;240:*.tmp=00;38;5;240:*.temp=00;38;5;240:*.o=00;38;5;240:*.pyc=00;38;5;240:*.class=00;38;5;240:*.cache=00;38;5;240:*.aac=00;38;5;166:*.au=00;38;5;166:*.flac=00;38;5;166:*.mid=00;38;5;166:*.midi=00;38;5;166:*.mka=00;38;5;166:*.mp3=00;38;5;166:*.mpc=00;38;5;166:*.ogg=00;38;5;166:*.ra=00;38;5;166:*.wav=00;38;5;166:*.m4a=00;38;5;166:*.axa=00;38;5;166:*.oga=00;38;5;166:*.spx=00;38;5;166:*.xspf=00;38;5;166:*.mov=00;38;5;166:*.mpg=00;38;5;166:*.mpeg=00;38;5;166:*.m2v=00;38;5;166:*.mkv=00;38;5;166:*.ogm=00;38;5;166:*.mp4=00;38;5;166:*.m4v=00;38;5;166:*.mp4v=00;38;5;166:*.vob=00;38;5;166:*.qt=00;38;5;166:*.nuv=00;38;5;166:*.wmv=00;38;5;166:*.asf=00;38;5;166:*.rm=00;38;5;166:*.rmvb=00;38;5;166:*.flc=00;38;5;166:*.avi=00;38;5;166:*.fli=00;38;5;166:*.flv=00;38;5;166:*.gl=00;38;5;166:*.m2ts=00;38;5;166:*.divx=00;38;5;166:*.webm=00;38;5;166:*.axv=00;38;5;166:*.anx=00;38;5;166:*.ogv=00;38;5;166:*.ogx=00;38;5;166:';
export LS_COLORS
