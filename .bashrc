# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ -f /usr/share/git/completion/git-completion.bash ]; then
     . /usr/share/git/completion/git-completion.bash
elif [ -f /mingw64/share/git/completion/git-completion.bash ]; then
     . /mingw64/share/git/completion/git-completion.bash
fi

for f in ~/.bashrc.d/*.bash; do source "$f"; done

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]'$'\n$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h \w'$'\n$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -lA'
alias la='ls -A'
#alias l='ls -CF'

# the dotfile alias for git:
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dt='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# This is a bit convoluted, the goal is to fix man pages - per default they use 
# some highlights which do clash with colorschemes that have a bright background.
# In order to fix that, we make less use a terminfo that sets those highlights to 
# sane values. The source of the terminfo is in ~/.terminfo/.src, to comile it, 
# use
#     tic ~/.terminfo/.src/mostlike.txt
# The following alias takes use of that compiles terminfo, makes man use less for 
# the output and shall result in a colored man page that is readable on all 
# sane terminal colorschemes.
alias man="TERMINFO=~/.terminfo/ LESS=C TERM=mostlike PAGER=less man" 

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/lib:$HOME/.local/lib:$LD_LIBRARY_PATH"

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Set shell into vi mode
set -o vi

#
# # In case we are not running in a graphical terminal, the DISPLAY
# # environment may not be set (this is usually the case when running in a
# # mintty which runs a cygwin/minGW bash).
# # On those cases, the assumption is that an X-server is running on a
# # defined display number on localhost. We set up the environment
# # accordingly.
# if [ -z "$DISPLAY" ]; then
#     export DISPLAY=127.0.0.1:1604.0
# fi
#
#
# # Typical ssh usage is to log in with a regular user account and gain
# # more permissions for system administration using sudo. However, in that
# # case x11 forwarding is broken since the log-in user is the one holding
# # the x11 credentials. If we are root, then normally we have access to the
# # log-in users Xauthority file and reuse his credentials.
# if [ "$USER" = "root" ]; then
#     LOGIN_USER=$( logname )
#     LOGIN_HOME=$( getent passwd "$LOGIN_USER" | cut -f6 -d: )
#     xauth add $( xauth -f "$LOGIN_HOME/.Xauthority" list | tail -1 )
# fi
#

# Source the default cargo environment (only applies if rust is instlled on the machine).
if [ -f  "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi
