fpath=($HOME/.zsh $fpath)

autoload -U compinit
compinit

zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*:default' menu select=2

setopt extended_glob
setopt auto_pushd
setopt listpacked
setopt autoremoveslash
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt share_history
setopt append_history
setopt numeric_glob_sort
setopt hist_reduce_blanks

setopt no_complete_aliases
setopt no_beep

HISTFILE="$HOME/.zsh_history"
HISTSIZE="10000"
SAVEHIST="10000"
REPORTTIME=3
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

NULL="/dev/null"

bindkey -e
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# For VCS (git, hg, etc...)
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn bzr hg
zstyle ':vcs_info:*' formats '(%s:%b)'
zstyle ':vcs_info:*' actionformats '(%s:%b[%a])'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true
precmd () {
    psvar=()
    LANG=en_US.UTF-8 vcs_info
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
    [[ -n "$SSH_AUTH_SOCK" ]] && psvar[2]="{`basename $SSH_AUTH_SOCK`}"
}
PROMPT="%F{green}%1v%f[%~]
[%n@%M(`uname -m`)%2v]%# "

#[[ -e "/etc/zsh/zprofile" ]] && source /etc/zsh/zprofile

#
# Set environment variables
#
#PATH="/sbin:/bin:/usr/sbin:/usr/lib/ccache/bin:/usr/bin"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/.rbenv/bin:$PATH"
PATH="/usr/lib/colorgcc/bin/:$HOME/bin:$PATH"
PATH="$HOME/go/bin:$PATH"
export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/X11R6/bin"
export CCACHE_PATH="/usr/bin"
export CCACHE_DIR="/tmp/ccache"
export CVS_RSH="ssh"
export HC_OPTS="-W"
# export GIT_SSH="$HOME/bin/ssh-github"
export VIRTUALENV_USE_DISTRIBUTE=1
export WORKON_HOME="$HOME/work/virtualenv"

function ealias() {
    alias $@
    local args="$@"
    args=${args%%\=*}
    zstyle -a ':globalias:var' filters filters
    filters+=(${args##* })
    zstyle ':globalias:var' filters $filters
}

if [ -x "`whence go`" ]; then
    export GOOS=`go env GOOS`
    export GOARCH=`go env GOARCH`
fi

if [ -x "`whence fzf`" ]; then
    if [ -x "`whence fd`" ]; then
        export FZF_DEFAULT_COMMAND='fd --type f'
    fi
    FZF_DEFAULT_OPTS=(
        --multi
        --color='fg+:-1,bg+:255,gutter:-1,hl:142,hl+:142'
        --layout=reverse
        --height='75%'
        --bind='ctrl-f:page-down,ctrl-b:page-up,tab:down,btab:up,ctrl-/:toggle+down,ctrl-^:toggle+down'
    )
    FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS"
    export FZF_DEFAULT_OPTS
fi

[ -n "$DISPLAY" ] && export LANG=ja_JP.UTF-8

#if [ -x "`whence llvm-gcc`" ]; then
#    export CC="llvm-gcc"
#    export CXX="llvm-g++"
#fi

if [ -x "`whence nvim`" ]; then
    export EDITOR="`whence nvim`"
    alias vi="`whence nvim`"
elif [ -x "`whence vim`" ]; then
    export EDITOR="`whence vim`"
    alias vi="`whence vim`"
else
    export EDITOR="`whence vi`"
fi

if [ -x "`whence lv`" ]; then
    export PAGER="`whence lv`"
    export LV="-c"
elif [ -x "`whence less`" ]; then
    export PAGER="`whence less`"
    export LESS="-isR"
    alias lv="less"
else
    export PAGER="/bin/more"
fi

#
# Set aliases
#

case "$OSTYPE" in
    linux*)
	alias ls="/bin/ls -A --color=auto"

    if [ -f "$HOME/.dircolors" ]; then
        eval "$(dircolors $HOME/.dircolors)"
    else
        export LS_COLORS='no=00:fi=00:di=01;36:ln=00;35:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32:'
    fi

    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

	alias -g pg="-pg -g -static -lc_p"
	;;
    freebsd*)
        alias ls="/bin/ls -AGw"
        ealias fetch="fetch -r"
        ;;
    *)
	alias ls="/bin/ls -A"
	;;
esac

# if [ -x "`whence mvn`" ]; then
    # alias mvn="`whence mvn` -DarchetypeGroupId=org.naniyueni -DarchetypeArtifactId=template -DarchetypeVersion=1.0 -DgroupId=org.naniyueni"
# fi

[[ -x "`whence -p rbenv`" ]] && eval "$(rbenv init -)"
[[ -x "`whence -p gmcs`" ]] && alias gmcs="gmcs -out:a.out" mcs=gmcs
[[ -x "`whence -p powerpill`" ]] && alias pacman="`whence powerpill` --nomessages"
[[ -x "`whence -p rascut`" ]] && alias rascut="_JAVA_OPTIONS=-Duser.language=en `whence rascut`"
[[ -x "`whence -p mplayer`" ]] && alias mplayer="`whence mplayer` -softvol"
[[ -x "`whence -p ctags`" ]] && alias ctags="ctags --sort=foldcase"
[[ -x "`whence -p tree`" ]] && ealias tree="tree --charset ascii"
[[ -x "`whence -p cdrecord`" ]] && alias cdrecord="cdrecord driveropts=burnfree"
[[ -x "`whence -p wodim`" ]] && alias wodim="wodim driveropts=burnfree"
[[ -x "`whence -p emacs`" ]] && ealias emacs="emacs -nw"
[[ -x "`whence -p display`" ]] && ealias display="display -geometry +0+0"
[[ -x "`whence -p rhino`" ]] && alias rhino="rlwrap java -jar /usr/share/java/js.jar"
[[ -x "`whence -p screen`" ]] && [ -n "$STY" ] && ealias exit="screen -d $STY"
[[ -x "`whence -p tmux`" ]] && [ -n "$TMUX" ] && ealias exit="tmux detach"
[[ -x "`whence -p dig`" ]] && ealias dig="dig +noedns"
[[ -x "`whence -p ios_webkit_debug_proxy`" ]] && ealias ios_webkit_debug_proxy="ios_webkit_debug_proxy -f http://chrome-devtools-frontend.appspot.com/static/18.0.1025.74/devtools.html"
if [ -x "`whence -p virtualenvwrapper.sh`" ]; then
    . "`whence -p virtualenvwrapper.sh`"
else
    [[ -x "`whence -p virtualenv`" ]] && ealias virtualenv="virtualenv --no-site-packages"
fi
if [ -x "`whence -p smlsharp`" ]; then
    if [ -x "`whence -p rlwrap`" ]; then
        alias smlsharp="rlwrap smlsharp"
    fi
fi
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
if [ -x "`whence -p hub`" ]; then
    eval "$(hub alias -s)"
fi

if [[ -x "$(whence -p direnv)" ]]; then
    eval "$(direnv hook zsh)"
fi

ealias ll="ls -l"
ealias lz="ll -Z"
alias df="df -h"
alias du="du -h"
ealias gprof="gprof -b"
alias grep="grep --color=auto -I"
# alias yaourt="yaourt --tmp /home/tmp"
ealias gp="git pull"
ealias sduo="sudo"
alias pipupgrade=$'pip list --outdated --format=legacy | awk \'{print $1}\' | xargs pip install -U pip'
ealias cdd='local dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"; unset dir'
ealias cdr='cd "$(git rev-parse --show-toplevel 2> /dev/null)"'

ealias -g F='| fzf'
ealias -g FV='| fzf | xargs -r $EDITOR'
ealias -g VV='| xargs -r $EDITOR'

# ulimit -c unlimited
umask 022
export NVM_DIR="$(readlink -f $HOME/.nvm)"
source $NVM_DIR/nvm.sh
source $NVM_DIR/bash_completion

function --antigen-init--() {
    antigen bundle mollifier/anyframe
    antigen bundle zsh-users/zsh-completions src
    antigen bundle junegunn/fzf shell/completion.zsh
    antigen bundle Aloxaf/fzf-tab
    antigen apply

    zstyle ":anyframe:selector:" use fzf
    bindkey "^R" anyframe-widget-put-history
    # bindkey "^T" anyframe-widget-insert-git-branch-all
    bindkey "^Xa" anyframe-widget-git-add

    ealias r="anyframe-widget-cd-ghq-repository-relative-path"

    FZF_TAB_COMMAND=(
        fzf
        --ansi
        --expect='$continuous_trigger,$print_query'
        --nth=2,3
        --delimiter='\x00'
        --height='${FZF_TMUX_HEIGHT:=75%}'
        --tiebreak=begin
        --cycle
        '--query=$query'
        '--header-lines=$#headers'
        --print-query
    )
    zstyle ':fzf-tab:*' command $FZF_TAB_COMMAND
    zstyle ':fzf-tab:*' no-group-color ''
}

function --auto-fu-init--() {
    AUTO_FU_NOCP=1
    zle-line-init () {auto-fu-init;}; zle -N zle-line-init
    # zstyle ':completion:*' completer _oldlist _complete
    # zle -N zle-keymap-select auto-fu-zle-keymap-select
    zstyle ':auto-fu:var' postdisplay $''
}

function --load-nvmrc-init--() {
    autoload -U add-zsh-hook
    add-zsh-hook chpwd load-nvmrc
    load-nvmrc
}

function --activate-venv-init--() {
    autoload -U add-zsh-hook
    add-zsh-hook chpwd activate-venv
    activate-venv
}

for plug in $HOME/.zsh/*.zsh; do
    if [[ -f "$plug" ]]; then
        . "$plug"
        local initfunc="--${${${plug##*/}%.zsh}#??-}-init--"
        if type -- "$initfunc" | grep -q 'function'; then
            "$initfunc"
        fi
    fi
done

if [[ -x "`whence -p gpg-agent`" ]]; then
    export GPG_TTY=$(tty)

    # Set SSH to use gpg-agent
    unset SSH_AGENT_PID
    if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
        export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    fi

    # Start the gpg-agent if not already running
    if ! pgrep -x -u "${USER}" gpg-agent >/dev/null 2>&1; then
        gpg-connect-agent /bye >/dev/null 2>&1
    fi

    # Refresh gpg-agent tty in case user switches into an X session
    gpg-connect-agent updatestartuptty /bye >/dev/null
fi

if [[ -x "`whence -p github-copilot-cli`" ]]; then
    eval "$(github-copilot-cli alias -- "$0")"
fi

function ssh-agent {
    eval `command ssh-agent`
    command ssh-add
}

function http_server {
    DIR=${1:="."}

    if [ -x "`whence python3`" ]; then
        (cd $DIR && python3 -m http.server 8000)
    elif [ -x "`whence python2`" ]; then
        (cd $DIR && python2 -m SimpleHTTPServer 8000)
    elif [ -x "`whence ruby`" ]; then
        (cd $DIR && ruby -rwebrick -e 'WEBrick::HTTPServer.new(:Port => 8000, :DocumentRoot => ".").start')
    fi
}

# function r {
    # if [ -z "$1" ]; then
        # ghq list | peco --query "github.com " | if read -r LINE; then
            # cd "$(ghq root)/$LINE"
        # fi
    # else
        # LINE="$(ls $2 | peco --initial-matcher Migemo | xargs -I '{}' -r echo "$2/{}")"
        # if [ -n "$LINE" ]; then
            # $1 "$LINE"
        # fi
    # fi
# }

function flash_cache {
    for ID in $( pgrep chrom ); do
        out=`LANG=C sudo ls -l /proc/$ID/fd | grep -E 'Flash|Pepper'`
        [ -z "$out" ] || (echo $out && echo /proc/$ID/fd/`echo "$out" | cut -d ' ' -f 9`)
    done
}

function linkcheck {
    URL=$1
    wget --spider --recursive --no-directories --no-verbose $URL
}

function pubkey-out {
    id_rsa=$1
    ssh-keygen -y -f $id_rsa
}

function codeline-count {
    grep -v -e '^$' -e '^//' $1/**/*.go | wc -l
}

function rtmp-suck {
    sudo iptables -t nat -A OUTPUT -p tcp --dport 1935 -m owner \! --uid-owner root -j REDIRECT
    sudo rtmpsuck
}

function filer {
    if [ -x "`whence pcmanfm`" ]; then
        pcmanfm
    elif [ -x "`whence rox`" ]; then
        rox
    fi
}

function encrypt {
    openssl aes-256-cbc -e -pbkdf2 -in "$1" -out /dev/stdout
}

function decrypt {
    openssl aes-256-cbc -d -pbkdf2 -in "$1" -out /dev/stdout
}

function getpubkey {
    curl https://github.com/naoina.keys
}

function ssh-keygen {
    command ssh-keygen "$@"
    echo -n "Enter file in which to save the key with encryption: "
    read privatekey
    mv "$privatekey" "$privatekey.tmp"
    openssl pkcs8 -topk8 -v2 des3 -in "$privatekey.tmp" -out "$privatekey"
    chmod 600 "$privatekey"
    rm -f "$privatekey.tmp"
}

function use {
    case "$1" in
        go*)
            if [ ! -x "$HOME/sdk/$1" ]; then
                if [ "$2" != "-u" ]; then
                    echo "$0: error: $1 not found" >&2
                    echo "Run \"$0 $1 -u\" to download $1 and use it" >&2
                    return 1
                fi
                local go=$(whence go)
                if [ ! -x "$go" ]; then
                    echo "executable go not found in \$PATH" >&2
                    return 1
                fi
                GO111MODULE=off $go get golang.org/dl/$1 && $1 download
            fi
            local execfile="$(whence $1)"
            local target="${execfile%/*}/go"
            echo "$execfile -> $target"
            ln -sf "$execfile" "$target"
            ;;
    esac
}

# Disable ^S
stty stop undef

# added by travis gem
[ -f /home/naoina/.travis/travis.sh ] && source /home/naoina/.travis/travis.sh