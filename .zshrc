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
    PATH="$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/local/texlive/2012/bin/x86_64-linux:/opt/local/bin:/opt/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin"
else
    PATH="$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/local/texlive/2012/bin/x86_64-darwin:/opt/local/bin:/opt/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin"
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
        alias ai='sudo aptitude install'
        alias auu='sudo aptitude update; sudo aptitude upgrade'
    else
        alias as='apt-cache search'
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

alias lsnew='/bin/ls -ahlt | head'
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
    alias crm='rm **/*.(err|out|log|pyc|dag.*)'
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
    rm **/*.(nav|snm|log|aux|out|toc|bbl|blg|dvi|synctex.gz|pdfsync|alg|acr|acn|glg|gls|glo|slg|syi|syg|ist|nlo|*~|fdb_latexmk|fls)
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

  # Schneller Start, Restart, Stop, Reload von init.d Modulen
  Start Restart Stop Reload() {
      sudo /etc/init.d/$1 ${0:l}
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
    [[ -f ~/.zkbd/${TERM}-${OSTYPE} ]] && printf '%s' ~/".zkbd/${TERM}-${OSTYPE}" && return 0
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
VIRTUALENVWRAPPER=/usr/local/bin/virtualenvwrapper_lazy.sh
[ -f $VIRTUALENVWRAPPER ] && source $VIRTUALENVWRAPPER

# dircolors:
LS_COLORS='no=00:fi=00:di=34:ow=34;40:ln=35:pi=30;44:so=35;44:do=35;44:bd=33;44:cd=37;44:or=05;37;41:mi=05;37;41:ex=01;31:*.cmd=01;31:*.exe=01;31:*.com=01;31:*.bat=01;31:*.reg=01;31:*.app=01;31:*.txt=32:*.org=32:*.md=32:*.mkd=32:*.h=32:*.c=32:*.C=32:*.cc=32:*.cpp=32:*.cxx=32:*.objc=32:*.sh=32:*.csh=32:*.zsh=32:*.el=32:*.vim=32:*.java=32:*.pl=32:*.pm=32:*.py=32:*.rb=32:*.hs=32:*.php=32:*.htm=32:*.html=32:*.shtml=32:*.erb=32:*.haml=32:*.xml=32:*.rdf=32:*.css=32:*.sass=32:*.scss=32:*.less=32:*.js=32:*.coffee=32:*.man=32:*.0=32:*.1=32:*.2=32:*.3=32:*.4=32:*.5=32:*.6=32:*.7=32:*.8=32:*.9=32:*.l=32:*.n=32:*.p=32:*.pod=32:*.tex=32:*.bmp=33:*.cgm=33:*.dl=33:*.dvi=33:*.emf=33:*.eps=33:*.gif=33:*.jpeg=33:*.jpg=33:*.JPG=33:*.mng=33:*.pbm=33:*.pcx=33:*.pdf=33:*.pgm=33:*.png=33:*.ppm=33:*.pps=33:*.ppsx=33:*.ps=33:*.svg=33:*.svgz=33:*.tga=33:*.tif=33:*.tiff=33:*.xbm=33:*.xcf=33:*.xpm=33:*.xwd=33:*.xwd=33:*.yuv=33:*.aac=33:*.au=33:*.flac=33:*.mid=33:*.midi=33:*.mka=33:*.mp3=33:*.mpa=33:*.mpeg=33:*.mpg=33:*.ogg=33:*.ra=33:*.wav=33:*.anx=33:*.asf=33:*.avi=33:*.axv=33:*.flc=33:*.fli=33:*.flv=33:*.gl=33:*.m2v=33:*.m4v=33:*.mkv=33:*.mov=33:*.mp4=33:*.mp4v=33:*.mpeg=33:*.mpg=33:*.nuv=33:*.ogm=33:*.ogv=33:*.ogx=33:*.qt=33:*.rm=33:*.rmvb=33:*.swf=33:*.vob=33:*.wmv=33:*.doc=31:*.docx=31:*.rtf=31:*.dot=31:*.dotx=31:*.xls=31:*.xlsx=31:*.ppt=31:*.pptx=31:*.fla=31:*.psd=31:*.7z=1;35:*.apk=1;35:*.arj=1;35:*.bin=1;35:*.bz=1;35:*.bz2=1;35:*.cab=1;35:*.deb=1;35:*.dmg=1;35:*.gem=1;35:*.gz=1;35:*.iso=1;35:*.jar=1;35:*.msi=1;35:*.rar=1;35:*.rpm=1;35:*.tar=1;35:*.tbz=1;35:*.tbz2=1;35:*.tgz=1;35:*.tx=1;35:*.war=1;35:*.xpi=1;35:*.xz=1;35:*.z=1;35:*.Z=1;35:*.zip=1;35:*.ANSI-30-black=30:*.ANSI-01;30-brblack=01;30:*.ANSI-31-red=31:*.ANSI-01;31-brred=01;31:*.ANSI-32-green=32:*.ANSI-01;32-brgreen=01;32:*.ANSI-33-yellow=33:*.ANSI-01;33-bryellow=01;33:*.ANSI-34-blue=34:*.ANSI-01;34-brblue=01;34:*.ANSI-35-magenta=35:*.ANSI-01;35-brmagenta=01;35:*.ANSI-36-cyan=36:*.ANSI-01;36-brcyan=01;36:*.ANSI-37-white=37:*.ANSI-01;37-brwhite=01;37:*.log=01;32:*~=01;32:*#=01;32:*.bak=01;33:*.BAK=01;33:*.old=01;33:*.OLD=01;33:*.org_archive=01;33:*.off=01;33:*.OFF=01;33:*.dist=01;33:*.DIST=01;33:*.orig=01;33:*.ORIG=01;33:*.swp=01;33:*.swo=01;33:*,v=01;33:*.gpg=34:*.gpg=34:*.pgp=34:*.asc=34:*.3des=34:*.aes=34:*.enc=34:*.sqlite=34:'
export LS_COLORS
