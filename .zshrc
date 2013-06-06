autoload -U compinit
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

compinit

zstyle ':completion::complete:*' use-cache 1

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
}
PROMPT="%F{green}%1v%f[%~]
[%n@%M(`uname -m`)]%# "

#[[ -e "/etc/zsh/zprofile" ]] && source /etc/zsh/zprofile

#
# Set environment variables
#
#PATH="/sbin:/bin:/usr/sbin:/usr/lib/ccache/bin:/usr/bin"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/.rbenv/bin:$HOME/.gem/ruby/1.9.1/bin:$PATH"
PATH="/usr/lib/colorgcc/bin/:$HOME/bin:/usr/lib/ccache/bin:$PATH"
export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/X11R6/bin"
export CCACHE_PATH="/usr/bin"
export CCACHE_DIR="/tmp/ccache"
export GREP_OPTIONS="--color=auto -I"
export CVS_RSH="ssh"
export JAVA_VERSION="1.6"
export HC_OPTS="-W"
# export GIT_SSH="$HOME/bin/ssh-github"
export VIRTUALENV_USE_DISTRIBUTE=1
export WORKON_HOME="$HOME/work/virtualenv"

[ -n "$DISPLAY" ] && export LANG=ja_JP.UTF-8

#if [ -x "`whence llvm-gcc`" ]; then
#    export CC="llvm-gcc"
#    export CXX="llvm-g++"
#fi

if [ -x "`whence vim`" ]; then
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
	export LS_COLORS='no=00:fi=00:di=01;36:ln=00;35:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32:'
	zstyle ':completion:*' list-colors 'di=01;36' 'ln=00;35' 'so=01;35' 'ex=01;32' 'bd=40;33;01' 'cd=40;33;01'
	alias -g pg="-pg -g -static -lc_p"
	;;
    freebsd*)
        alias ls="/bin/ls -AGw"
        alias fetch="fetch -r"
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
[[ -x "`whence -p tree`" ]] && alias tree="tree --charset ascii"
[[ -x "`whence -p cdrecord`" ]] && alias cdrecord="cdrecord driveropts=burnfree"
[[ -x "`whence -p wodim`" ]] && alias wodim="wodim driveropts=burnfree"
[[ -x "`whence -p emacs`" ]] && alias emacs="emacs -nw"
[[ -x "`whence -p display`" ]] && alias display="display -geometry +0+0"
[[ -x "`whence -p rhino`" ]] && alias rhino="rlwrap java -jar /usr/share/java/js.jar"
[[ -x "`whence -p screen`" ]] && [ -n "$STY" ] && alias exit="screen -d $STY"
[[ -x "`whence -p tmux`" ]] && [ -n "$TMUX" ] && alias exit="tmux detach"
if [ -x "`whence -p virtualenvwrapper.sh`" ]; then
    . "`whence -p virtualenvwrapper.sh`"
else
    [[ -x "`whence -p virtualenv`" ]] && alias virtualenv="virtualenv --no-site-packages"
fi

alias ll="ls -l"
alias lz="ll -Z"
alias df="df -h"
alias du="du -h"
alias gprof="gprof -b"
# alias yaourt="yaourt --tmp /home/tmp"

# ulimit -c unlimited
umask 022

source $HOME/.zsh/git-completion.bash

source $HOME/.zsh/auto-fu.zsh/auto-fu.zsh
zle-line-init () {auto-fu-init;}; zle -N zle-line-init
zstyle ':completion:*' completer _oldlist _complete
zle -N zle-keymap-select auto-fu-zle-keymap-select
zstyle ':auto-fu:var' postdisplay $''
source $HOME/.nvm/nvm.sh
source $HOME/.nvm/bash_completion

function http_server {
    DIR=${1:="."}

    if [ -x "`whence python3`" ]; then
        (cd $DIR && python3 -m http.server)
    elif [ -x "`whence python2`" ]; then
        (cd $DIR && python2 -m SimpleHTTPServer)
    fi
}
